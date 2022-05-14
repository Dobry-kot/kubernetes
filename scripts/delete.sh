HOST1=51.250.87.176
HOST2=51.250.70.241
HOST3=51.250.77.118

# ssh dkot@$HOST1 'sudo rm -rf /etc/kubernetes/pki/certs/etcd/system\:etcd-server*'
# ssh dkot@$HOST2 'sudo rm -rf /etc/kubernetes/pki/certs/etcd/system\:etcd-server*'
# ssh dkot@$HOST3 'sudo rm -rf /etc/kubernetes/pki/certs/etcd/system\:etcd-server*'



ssh dkot@$HOST1 'sudo systemctl stop etcd'
ssh dkot@$HOST2 'sudo systemctl stop etcd'
ssh dkot@$HOST3 'sudo systemctl stop etcd'