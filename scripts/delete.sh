HOST1=51.250.68.214
HOST2=51.250.86.17
HOST3=51.250.82.99

# ssh dkot@$HOST1 'sudo rm -rf /pki'
# ssh dkot@$HOST2 'sudo rm -rf /pki'
# ssh dkot@$HOST3 'sudo rm -rf /pki'


# ssh dkot@$HOST1 'sudo rm -rf /etc/kubernetes'
# ssh dkot@$HOST2 'sudo rm -rf /etc/kubernetes'
# ssh dkot@$HOST3 'sudo rm -rf /etc/kubernetes'

# ssh dkot@$HOST1 'sudo rm -rf /var/lib/etcd'
# ssh dkot@$HOST2 'sudo rm -rf /var/lib/etcd'
# ssh dkot@$HOST3 'sudo rm -rf /var/lib/etcd'

ssh dkot@$HOST1 'sudo rm -f /etc/systemd/system/kubelet.service'
ssh dkot@$HOST2 'sudo rm -f /etc/systemd/system/kubelet.service'
ssh dkot@$HOST3 'sudo rm -f /etc/systemd/system/kubelet.service'