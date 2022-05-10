

HOST_1=cl11erbm03uhlfvrl4tp-uzav
HOST_2=cl11erbm03uhlfvrl4tp-yxox
HOST_3=cl11erbm03uhlfvrl4tp-ufow
ENDPOINTS=$HOST_1:2379,$HOST_2:2379,$HOST_3:2379
etcdctl \
--write-out=table \
--endpoints=$ENDPOINTS \
--cert /pki/certs/system:etcd-peer.pem \
--key /pki/certs/system:etcd-peer-key.pem \
--cacert /pki/ca/etcd-ca.pem \
endpoint status


kubeadm init phase upload-config kubeadm --config kubeadmcfg.yaml --kubeconfig=/etc/kubernetes/kube-apiserver/kubeconfig 

kubectl patch configmap -n kube-system kubeadm-config \
      -p '{"data":{"ClusterStatus":"apiEndpoints: {}\napiVersion: kubeadm.k8s.io/v1beta2\nkind: ClusterStatus"}}'
    
kubeadm init phase upload-config kubelet --config kubeadmcfg.yaml --kubeconfig=/etc/kubernetes/kube-apiserver/kubeconfig  -v1 2>&1 |
      while read line; do echo "$line" | grep 'Preserving the CRISocket information for the control-plane node' && killall kubeadm || echo "$line"; done

flatconfig=$(mktemp)
kubectl config view --flatten > "$flatconfig"

kubeadm init phase bootstrap-token --config kubeadmcfg.yaml  --skip-token-print --kubeconfig="$flatconfig"
rm -f "$flatconfig"

# correct apiserver address for the external clients
kubectl apply -n kube-public -f - <<EOT
apiVersion: v1
kind: ConfigMap
metadata:
    name: cluster-info
    namespace: kube-public
data:
    kubeconfig: |
        apiVersion: v1
        clusters:
        - cluster:
            certificate-authority-data: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJakNDQWdxZ0F3SUJBZ0lVTExRaWtyMWJpMHF5c20wc3BQdUVsMFRRdFE4d0RRWUpLb1pJaHZjTkFRRUwKQlFBd0tURVNNQkFHQTFVRUN4TUpSRzlpY25rdGEyOTBNUk13RVFZRFZRUURFd3BMZFdKbGNtNWxkR1Z6TUI0WApEVEl5TURVeE1ERTBNRGN3TUZvWERUSTNNRFV3T1RFME1EY3dNRm93S1RFU01CQUdBMVVFQ3hNSlJHOWljbmt0CmEyOTBNUk13RVFZRFZRUURFd3BMZFdKbGNtNWxkR1Z6TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEEKTUlJQkNnS0NBUUVBNXFPSjFQaWJHMGo5c0V1b1k0Ylo3aE5YRE85WXQrazRZV0NZQW95Z201dmtDK1psYjl5MwoyUEI1ZnpsSG5SWXl2dkY2NXFwR0lqb2pTUWo1V2JuVUdZd1dZVTlyNXBjclVROWVCUUt1Y0xzY1VyQ1U4ZC8zCmtkQ3d0cUFrREY4eVFydmJsREZHUjFlZ1ZDcHB1WjY2RUZ3cE9yZm9wSHBmYkhVaWVDQUJNeHRBUkxkeFpxYSsKcTNCVHpYcmZnQ2J3N1czMDNqZ0dHZUozSjZTNnVtZ3F2QmVVR1hOUUxNUW1ZVUhIZzlwZ3haN3JYTnl4cFVNZQpVdkRQeDd0Y2xZRHF5K3FNY0pveGVTMGNKbW5kMXhJQkI0b1dGYXVHekxUQ2tHUllHcTUyNTg5eHJXRjFTNUI4CkMybEZ2UjliV1k1Y3FiUkJuQlhTaGdVMjhxdEFUdXp5d1FJREFRQUJvMEl3UURBT0JnTlZIUThCQWY4RUJBTUMKQVFZd0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBZEJnTlZIUTRFRmdRVStoRlllS3dkd0JHenlieXZ5THJyYno5KwpoM2d3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUxpVDRHc2pTY1BGaE9pS3FLTDlhYmdyWmdPUzN2MW4wZU03ClhHQXkzTEEwWTNsdmlPMUFLTVFBYWVhRTl4ZmQxWHJBUXVVbXIzZm9WTm15QXZQVXZOWG1wVzNLNWM0cmw3bXgKYTk4RE9ETXR2K3J5MVpVRXd0aDhwa3NiZUVzc0xUNXkxSlowa2NFZUMwOE9MWk9aSlJBVmFCNjUrdUFlNmtnNgpFc2g2ZVpYbXhXZ3JER2c1REV4WlFHTnNiVXEzYldEQkVkVEU1WUJjU2hkTEpTN3BSWlZLa0NRaU1HRWI0blhqCjBZWHA2Sm44ckpRZDVpck1HT2ZmTGtZRDhtZzE5VGVCZ1VIN2FnZldhMmdKdFplMGVRVFhxZFVCNU5lMERNa1gKekliSWYwM2R0TVVhUkxZYWdUbzNhWDh0cTdhK2puMy94aU05V2FvQkFXNjYvM2VTZjZVPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
            server: https://51.250.4.42:6443
        name: ""
        contexts: null
        current-context: ""
        kind: Config
        preferences: {}
        users: null
EOT

kubeadm join 51.250.4.42:6443 --token yhodlm.72m06150wtpw8yd6 --discovery-token-ca-cert-hash sha256:cb125735f3a43075e73d6b5c6fa15b0255e6821859875edfb1fede3d96771446



[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
