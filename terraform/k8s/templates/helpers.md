  # - path: /etc/kubernetes/kubelet/bootstrap-kubeconfig
  #   owner: root:root
  #   permissions: '0644'
  #   content: |
  #     ---
  #     apiVersion: v1
  #     clusters:
  #     - cluster:
  #         certificate-authority: /etc/kubernetes/pki/ca/kubernetes-ca.pem
  #         server: https://127.0.0.1:6443
  #       name: bootstrap
  #     contexts:
  #     - context:
  #         cluster: bootstrap
  #         user: kubelet-bootstrap
  #       name: bootstrap
  #     current-context: bootstrap
  #     kind: Config
  #     preferences: {}
  #     users:
  #     - name: kubelet-bootstrap
  #       user:
  #         token: 255120.2e8de3467d070f20