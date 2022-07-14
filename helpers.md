curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add cilium https://helm.cilium.io/
helm repo add coredns https://coredns.github.io/helm

crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps -a
export KUBECONFIG=/etc/kubernetes/kube-apiserver/kubeconfig
kubectl get no

container=$(crictl --runtime-endpoint unix:///run/containerd/containerd.sock ps -a | grep cilium-agent | awk '{print $1}')
PID=$(crictl inspect $container | grep pid )
nsenter --target    1839   --mount --uts   --ipc   --net   --pid


helm upgrade --install --namespace kube-system cilium cilium/cilium  --version 1.11.6 \
--values - <<EOF
kubeProxyReplacement: strict
k8sServiceHost: api.cluster-1.dobry-kot.ru
k8sServicePort: 6443

ipam:
  mode: "cluster-pool"
  operator:
    clusterPoolIPv4PodCIDR: 10.220.0.0/16
    clusterPoolIPv4MaskSize: 26

containerRuntime:
  integration: containerd
  socketPath: /run/containerd/containerd.sock

cluster:
  name: cluster-2
  id: 12

hubble:
  enabled: true
  relay:
    enabled: true
  ui:
    enabled: true
    tls:
      enabled: true
      auto:
        enabled: true
l2NeighDiscovery:
  enabled: false
tunnel: disabled
prometheus:
  enabled: true
  port: 9090
proxy:
  prometheus:
    enabled: true
    port: 9095
wellKnownIdentities:
  enabled: true
enableK8sEventHandover: true
endpointRoutes:
  enabled: true 
autoDirectNodeRoutes: false
enableIPv4Masquerade: true
hostPort:
  enabled: true
hostServices:
    enabled: true
    hostNamespaceOnly: true
bgp:
  enabled: true
  announce:
    loadbalancerIP: true
    podCIDR: true
EOF



helm upgrade coredns coredns/coredns \
--install \
--namespace=kube-system \
--values - <<EOF
fullnameOverride: coredns

replicaCount: 3

globalLabels:
  k8sApp: kube-dns

environments:
  - name: GOMAXPROCS
    value: '2'

rollingUpdate:
  maxUnavailable: 1
  maxSurge: 35%

terminationGracePeriodSeconds: 30
podAnnotations: {}
serviceType: "ClusterIP"

prometheus:
  service:
    enabled: false
    annotations:
      prometheus.io/scrape: "true"
      prometheus.io/port: "9153"
  monitor:
    enabled: false
    additionalLabels: {}
    namespace: ""

serviceAccount:
  create: true
  name: coredns

rbac:
  create: true
  pspEnable: true

priorityClassName: "system-cluster-critical"



# podDisruptionBudget:
#   minAvailable: 2

# Default zone is what Kubernetes recommends:
# https://kubernetes.io/docs/tasks/administer-cluster/dns-custom-nameservers/#coredns-configmap-options
servers:
- zones:
  - zone: .
  port: 53
  plugins:
  - name: errors
  # Serves a /health endpoint on :8080, required for livenessProbe
  - name: health
    configBlock: |-
      lameduck 5s
  # Serves a /ready endpoint on :8181, required for readinessProbe
  - name: ready
  # Required to query kubernetes API for data
  - name: kubernetes
    parameters: cluster.local in-addr.arpa ip6.arpa
    configBlock: |-
      pods verified
      fallthrough in-addr.arpa ip6.arpa
      ttl 30
  # Serves a /metrics endpoint on :9153, required for serviceMonitor
  - name: prometheus
    parameters: 0.0.0.0:9153
  - name: forward
    parameters: . /etc/resolv.conf
  - name: cache
    parameters: 30
  - name: loop
  - name: reload
  - name: loadbalance
    parameter: round_robin

customLabels: {}

service:
  clusterIP: "29.64.0.10"
EOF


alias kn='kubectl config set-context --current '
alias kg='kubectl get'
alias ka='kubectl apply'
alias kd='kubectl delete'
alias ki='kubectl describe'
alias ke='kubectl edit'
alias k='kubectl '
alias kl='kubectl logs '
alias ees='etcd_endpoints '
alias cll='kubectl config get-contexts'
alias cle='kubectl config use-context '


cat <<EOF > ~/.kube/config
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /etc/kubernetes/pki/ca/root-ca.pem
    server: https://api.cluster-1.dobry-kot.ru:6443
  name: pfm-stage-1
- cluster:
    certificate-authority: /etc/kubernetes/pki/ca/root-ca2.pem
    server: https://api.cluster-2.dobry-kot.ru:6443
  name: pfm-stage-2
contexts:
- context:
    cluster: pfm-stage-1
    namespace: kube-system
    user: kubernetes-admin-1
  name: kubernetes-admin-1
- context:
    cluster: pfm-stage-2
    namespace: kube-system
    user: kubernetes-admin-2
  name: kubernetes-admin-2
current-context: kubernetes-admin-1
kind: Config
preferences: {}
users:
- name: kubernetes-admin-1
  user:
    client-certificate: /etc/kubernetes/pki/certs/kube-apiserver/system:kube-apiserver-kubelet-client.pem
    client-key: /etc/kubernetes/pki/certs/kube-apiserver/system:kube-apiserver-kubelet-client-key.pem
- name: kubernetes-admin-2
  user:
    client-certificate: /etc/kubernetes/pki/certs/kube-apiserver/system:kube-apiserver-kubelet-client2.pem
    client-key: /etc/kubernetes/pki/certs/kube-apiserver/system:kube-apiserver-kubelet-client-key2.pem
EOF


HOST_1=master-0.cluster-1.dobry-kot.ru
HOST_2=master-1.cluster-1.dobry-kot.ru
HOST_3=master-2.cluster-1.dobry-kot.ru

ENDPOINTS=$HOST_1:2379,$HOST_2:2379,$HOST_3:2379
etcdctl \
--write-out=table \
--endpoints=$ENDPOINTS \
--cert /etc/kubernetes/pki/certs/etcd/system:etcd-healthcheck-client.pem \
--key /etc/kubernetes/pki/certs/etcd/system:etcd-healthcheck-client-key.pem \
--cacert /etc/kubernetes/pki/ca/etcd-ca.pem \
endpoint status


HOST_1=10.128.0.23
HOST_2=10.128.0.10
HOST_3=10.128.0.29
HOST_4=10.128.0.35
ENDPOINTS=$HOST_1:2379,$HOST_2:2379,$HOST_3:2379,$HOST_4:2379
etcdctl \
--write-out=table \
--endpoints=$ENDPOINTS \
--cert /etc/kubernetes/pki/etcd/healthcheck-client.crt \
--key /etc/kubernetes/pki/etcd/healthcheck-client.key \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
endpoint status



etcdctl --endpoints=$ENDPOINTS --cert /etc/kubernetes/pki/etcd/healthcheck-client.crt --key /etc/kubernetes/pki/etcd/healthcheck-client.key --cacert /etc/kubernetes/pki/etcd/ca.crt  --peer-urls=https://10.128.0.29:2380  --listen-peer-urls=http://https://10.128.0.29:2380,https://127.0.0.1:2379 --listen-client-urls=https://10.128.0.29:2379,https://127.0.0.1:2379 --advertise-client-urls=https://10.128.0.29:2379:2379,https://127.0.0.1:2379 member add cl1l8jh7j18ubba32ue1-oqiv 

etcd -name infra1 \
-listen-peer-urls http://10.0.1.13:2380 \
-listen-client-urls http://10.0.1.13:2379,http://127.0.0.1:2379 \
-advertise-client-urls http://10.0.1.13:2379,http://127.0.0.1:2379

curl -sLO https://git.io/cilium-sysdump-latest.zip && python cilium-sysdump-latest.zip