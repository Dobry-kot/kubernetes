

HOST_1=cl15tk4od57v58kegou7-esac
HOST_2=cl15tk4od57v58kegou7-uvuh
HOST_3=cl15tk4od57v58kegou7-aqop
ENDPOINTS=$HOST_1:2379,$HOST_2:2379,$HOST_3:2379
etcdctl \
--write-out=table \
--endpoints=$ENDPOINTS \
--cert /etc/kubernetes/pki/certs/etcd/system:etcd-peer.pem \
--key /etc/kubernetes/pki/certs/etcd/system:etcd-peer-key.pem \
--cacert /etc/kubernetes/pki/ca/etcd-ca.pem \
endpoint status

