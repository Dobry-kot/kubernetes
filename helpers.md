

HOST_1=cl11erbm03uhlfvrl4tp-uzav
HOST_2=cl11erbm03uhlfvrl4tp-yxox
HOST_3=cl11erbm03uhlfvrl4tp-ufow
ENDPOINTS=$HOST_1:2379,$HOST_2:2379,$HOST_3:2379
etcdctl \
--write-out=table \
--endpoints=$ENDPOINTS \
--cert /pki/certs/etcd/system:etcd-peer.pem \
--key /pki/certs/etcd/system:etcd-peer-key.pem \
--cacert /pki/ca/etcd-ca.pem \
endpoint status

