

HOST_1=cl1e26er158kjnao7pmo-aluw
HOST_2=cl1e26er158kjnao7pmo-uvuz
HOST_3=cl1e26er158kjnao7pmo-uhoj
ENDPOINTS=$HOST_1:2379,$HOST_2:2379,$HOST_3:2379
etcdctl \
--write-out=table \
--endpoints=$ENDPOINTS \
--cert /etc/kubernetes/pki/certs/etcd/system:etcd-peer.pem \
--key /etc/kubernetes/pki/certs/etcd/system:etcd-peer-key.pem \
--cacert /etc/kubernetes/pki/ca/etcd-ca.pem \
endpoint status

