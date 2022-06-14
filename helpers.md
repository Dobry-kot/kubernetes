

HOST_1=51.250.3.242
HOST_2=51.250.5.96
HOST_3=51.250.11.235

ENDPOINTS=10.146.248.144:2379,10.146.248.160:2379
etcdctl \
--write-out=table \
--endpoints=$ENDPOINTS \
--cert /var/lib/etcd-secrets/tls.crt \
--key /var/lib/etcd-secrets/tls.key \
--cacert /var/lib/etcd-secrets/ca.crt \
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