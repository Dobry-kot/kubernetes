ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix


helm repo add cilium https://helm.cilium.io/
helm upgrade cilium cilium/cilium --version 1.11.3 \
    --install \
    --set kubeProxyReplacement=strict \
    --set k8sServiceHost=51.250.4.42 \
    --set k8sServicePort=6443