HOST1=51.250.3.242
HOST2=51.250.5.96
HOST3=51.250.11.235

ssh dkot@$HOST1 'sudo rm -rf /etc/systemd/system/kubelet.service.d'
ssh dkot@$HOST2 'sudo rm -rf /etc/systemd/system/kubelet.service.d'
ssh dkot@$HOST3 'sudo rm -rf /etc/systemd/system/kubelet.service.d'

