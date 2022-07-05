

HOST_1=firecube-master-0.example.com
HOST_2=firecube-master-1.example.com
HOST_3=firecube-master-2.example.com

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