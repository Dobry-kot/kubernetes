HOST1=51.250.14.5
HOST2=51.250.70.241
HOST3=51.250.78.145

ssh dkot@$HOST1 'sudo rm -rf /etc/kubernetes/manifests/*'
ssh dkot@$HOST2 'sudo rm -rf /etc/kubernetes/manifests/*'
ssh dkot@$HOST3 'sudo rm -rf /etc/kubernetes/manifests/*'

ssh dkot@$HOST1 'sudo shutdown -r now'
ssh dkot@$HOST2 'sudo shutdown -r now'
ssh dkot@$HOST3 'sudo shutdown -r now'