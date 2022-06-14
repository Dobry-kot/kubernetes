"""A Python Pulumi program"""

import pulumi
import pulumi_yandex as yandex
import os
from pulumi import Output
from jinja2 import Template
import base64

base_domain             = "example.com"
masters                 = 3
ssh_keys_path           = os.path.expanduser("~/.ssh/id_rsa.pub")
cluster_name            = "firecube"
instance_master_name    = "{cluster_name}-master".format(cluster_name=cluster_name)
vpc_name                = "{cluster_name}-vpc".format(cluster_name=cluster_name)
vpc_subnet_name         = "{vpc_name}-subnet".format(vpc_name=vpc_name)
lb_api                  = "{cluster_name}-lb-api".format(cluster_name=cluster_name)
lb_target_api           = "{cluster_name}-lb-target-api".format(cluster_name=cluster_name)
dns_zone_name           = "{cluster_name}-dns-zone".format(cluster_name=cluster_name)
vpc_subnets             = {
    "zone_a": [
        "10.1.0.0/16"
    ]
}
with open(ssh_keys_path) as ssh_key_data: 
    ssh_key_content = ssh_key_data.read()

vpc = yandex.VpcNetwork(vpc_name)

vpc_subnet_a = yandex.VpcSubnet("%s-a" %vpc_subnet_name,
    opts=pulumi.ResourceOptions(parent=vpc),
    network_id=vpc.id,
    v4_cidr_blocks=vpc_subnets.get("zone_a"),
    zone="ru-central1-a")

dns_zone = yandex.DnsZone(dns_zone_name,
    description="desc",
    labels={
        "label1": "label-1-value",
    },
    zone="example.com.",
    public=False,
    private_networks=[vpc.id])

lb_api_target_group     = yandex.LbTargetGroup(
    lb_target_api,targets=[],
    )

load_balancer_api = yandex.LbNetworkLoadBalancer(lb_api,
    opts=pulumi.ResourceOptions(depends_on=[vpc_subnet_a],parent=lb_api_target_group,),
    attached_target_groups=[yandex.LbNetworkLoadBalancerAttachedTargetGroupArgs(
        healthchecks=[yandex.LbNetworkLoadBalancerAttachedTargetGroupHealthcheckArgs(
            tcp_options=yandex.LbNetworkLoadBalancerAttachedTargetGroupHealthcheckHttpOptionsArgs(
                port=6443,
            ),
            name="tcp",
        )],
        target_group_id=lb_api_target_group.id,
    )],
    listeners=[yandex.LbNetworkLoadBalancerListenerArgs(
        external_address_spec=yandex.LbNetworkLoadBalancerListenerExternalAddressSpecArgs(
            ip_version="ipv4",
        ),
        name="my-listener",
        port=6443,
    )])

def render_cloud_init2(listener, instance_id):
    print(ssh_key_content)
    template_content = open('cloud-init.yaml.j2').read()
    template = Template(template_content)
    config_vars=dict()
    config_vars['api_server']=dict()
    config_vars['api_server']['etcd_server'] = 'https'
    config_vars['api_server']['service_cidr'] = "29.64.0.0/16"

    a = listener.apply(lambda v: template.render(external_ip=v, 
                                                 config_vars=config_vars, 
                                                 ssh_key_content=ssh_key_content,
                                                 instance_index=instance_id,
                                                 instance_master_name=instance_master_name,
                                                 base_domain=base_domain))

    return a

external_ip = load_balancer_api.listeners[0].external_address_spec.address

for instance_id in range(masters):

    instance = yandex.ComputeInstance("%s-%s" %(instance_master_name,instance_id),
        opts=pulumi.ResourceOptions(depends_on=[load_balancer_api],parent=load_balancer_api),
        name="%s-%s" %(instance_master_name,instance_id),
        boot_disk=yandex.ComputeInstanceBootDiskArgs(
            initialize_params=yandex.ComputeInstanceBootDiskInitializeParamsArgs(
                image_id="fd8l1com1tts4fr2dukt",
            ),
        ),
        labels= {
            "node-role.kubernetes.io/master": "true"
        },
            
        metadata={
            "user-data": render_cloud_init2(external_ip, instance_id),
        },
        network_interfaces=[yandex.ComputeInstanceNetworkInterfaceArgs(
            subnet_id=vpc_subnet_a.id,
            nat=True
        )],
        platform_id="standard-v1",
        resources=yandex.ComputeInstanceResourcesArgs(
            core_fraction=20,
            cores=2,
            memory=4,
        ),
        allow_stopping_for_update=True,
        zone="ru-central1-a")

# for instance_id in range(masters):
    record = yandex.DnsRecordSet("master-%s" %(instance_id),
        zone_id=dns_zone.id,
        type="A",
        ttl=60,
        name="%s-%s" %(instance_master_name,instance_id),
        datas=[instance.network_interfaces[0].ip_address.apply(lambda v: v)],
        opts=pulumi.ResourceOptions(parent=instance),)
        