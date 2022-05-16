HOST1=51.250.4.34
HOST2=51.250.11.11
HOST3=51.250.69.105

ssh dkot@$HOST1 'sudo rm -rf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf'
ssh dkot@$HOST2 'sudo rm -rf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf'
ssh dkot@$HOST3 'sudo rm -rf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf'

