

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


kubeadm init phase upload-config kubeadm --config /etc/kubernetes/kubeadm/kubeadmcfg.yaml --kubeconfig=/etc/kubernetes/kube-apiserver/kubeconfig 

kubectl patch configmap -n kube-system kubeadm-config \
      -p '{"data":{"ClusterStatus":"apiEndpoints: {}\napiVersion: kubeadm.k8s.io/v1beta2\nkind: ClusterStatus"}}'
    
kubeadm init phase upload-config kubelet --config /etc/kubernetes/kubeadm/kubeadmcfg.yaml --kubeconfig=/etc/kubernetes/kube-apiserver/kubeconfig  -v1 2>&1 |
      while read line; do echo "$line" | grep 'Preserving the CRISocket information for the control-plane node' && killall kubeadm || echo "$line"; done

flatconfig=$(mktemp)
kubectl config view --flatten > "$flatconfig"

kubeadm init phase bootstrap-token --config /etc/kubernetes/kubeadm/kubeadmcfg.yaml  --skip-token-print --kubeconfig="$flatconfig"
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
            certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJakNDQWdxZ0F3SUJBZ0lVZHRFNVF0K2tmTWdaaWNUUlc3MnZ5RjBRZUJnd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0tURVNNQkFHQTFVRUN4TUpSRzlpY25rdGEyOTBNUk13RVFZRFZRUURFd3BMZFdKbGNtNWxkR1Z6TUI0WApEVEl5TURVeE1qSXpORE13TUZvWERUSTNNRFV4TVRJek5ETXdNRm93S1RFU01CQUdBMVVFQ3hNSlJHOWljbmt0CmEyOTBNUk13RVFZRFZRUURFd3BMZFdKbGNtNWxkR1Z6TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEEKTUlJQkNnS0NBUUVBdmVidWYxWVMvYytuc2lsSDJ2ODZlTDFrRkc4aGdhMnZ4OHdSdGNhNUdxYVoxbFUrK2pZMgoxY2FSdE1uY3U0OERNd0IvcUdxV0FVZ2hCV0xnalZPQ0hOc3dPMnVpZzI0dlQ5alNHSEh6UTB4N2RJOEp0TG4vCk0rNldsWlYzWExhSnY4V0Rydi9TL2d2cXd4SkowQ2hsb2o1ZG9CR3NSTjNHUzdOaFVFWTBXOVdwcVBybk9pVGEKbFFzK000a0pOUW5YbGZIM1ROVjA4RzFiNTBLUSt4Wi9JVWpKeVk1eEJPVmJPSTVxRVliY0VXNytvOWdRRkMraAo5ZVpOb2dwZEc4RFc4dHA2OGZiTHYyMDhPekp5RStROGticVhFZm91QWpvQXd2ZXFnSFBGeWxJZXY4UHNsaWVGCkJGay9oUXBYTFdKc25jYy9qbUl5N1RmZStSVDZSaUJwK1FJREFRQUJvMEl3UURBT0JnTlZIUThCQWY4RUJBTUMKQVFZd0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBZEJnTlZIUTRFRmdRVStiZFhwYWtvZHluYVErNElqVjdLY1FBOAovaWN3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUljT0dHNFZHb3lGalBQZy9FbHVyN1FsbDVDMzZDcXRyVE1BCmtabWVoOFJhSlZseEhEUFVrdFNocjdqUFZNbGlVODI0K0NiSTBiUnRzSjJDNjVYN0kxaklSajM5bXgrQUw4MFQKTjJEMTJHMEVGK3ZxQXh6eTdaNTFPM1hRamlKbWxhU1ZJVnM2M3RneGE0Q1ZlT0Z4cEtqQmlhL1ZldVphUjBmMgpMaE9vck02THlFYkhQaGxFazBwMTI1WHZabFZKbkk5Qi9oaDMwMzlOWGhPc09hNXZuSjllOUp0LzgxajNBd0wxCjdMdWQxNFdsU2J4SFJNSUxMdWxkYWw1T2JwTFJLTXpzMDEyR2FHelJFL3Z4Q2w4RHRKdTRtUUdaclh3dVNURjEKOGg0b01MSnRVY3VHV1EwZTFCTUd0WllqdGRHVlZsa2tvKzUzZHJyZit3UFNxdWJNeGdzPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
            server: https://51.250.4.42:6443
        name: ""
        contexts: null
        current-context: ""
        kind: Config
        preferences: {}
        users: null
EOT

base64_encoded_ca="$(base64 -w0 /pki/ca/root-ca.pem)"

kubectl get cm/cluster-info --namespace kube-public -o yaml | \
    /bin/sed "s/\(certificate-authority-data:\).*/\1 ${base64_encoded_ca}/" | \
    kubectl apply -f -




kubeadm join 51.250.4.42:6443 --token yhodlm.72m06150wtpw8yd6 --discovery-token-ca-cert-hash sha256:cb125735f3a43075e73d6b5c6fa15b0255e6821859875edfb1fede3d96771446

kubeadm join 51.250.4.42:6443 --token vgbhbb.0xcgjl07sz514sk7 --discovery-token-ca-cert-hash sha256:ce159ec44cf2335e4cd8d7eb15ece9585602b555e4b2108eb4423618c88a8ede 
kubeadm join 51.250.4.42:6443 --token 56isli.r6z1bn7ivz4h3hd3 --discovery-token-ca-cert-hash sha256:2a2265b8287148001581adfc8c915cb5bbe52de4bedab4ecb2026d05539b4c5c

[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace

kubeadm join 127.0.0.1:6443 --token onpjzo.l6hg7qcual0kk3r9 --discovery-token-ca-cert-hash sha256:cb125735f3a43075e73d6b5c6fa15b0255e6821859875edfb1fede3d96771446 
.

[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace

-----BEGIN CERTIFICATE-----
MIIDIjCCAgqgAwIBAgIUKsNjvG9dbbyVeu0L+5g2EVIvwWowDQYJKoZIhvcNAQEL
BQAwKTESMBAGA1UECxMJRG9icnkta290MRMwEQYDVQQDEwpLdWJlcm5ldGVzMB4X
DTIyMDUwNjIxNDEwMFoXDTI3MDUwNTIxNDEwMFowKTESMBAGA1UECxMJRG9icnkt
a290MRMwEQYDVQQDEwpLdWJlcm5ldGVzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
MIIBCgKCAQEArsCf6t6CQ0wvGQFPYPSZ2r+fBXwkx1OxK3y2Pvlw49pWad1Xr8jU
6CsE5Y75mbVMx4XodvIeRPofdW3eJEcNy7fZ5aIbHS9uc2z1FwW3Ob1FZGRNScQ9
k4ZoViPWoewdEnNC6qXhwuxQ4FQ863DDZ4aIWCiLfs/BsK3MWQBbjX21b8BpMxEx
oPmpga6rLm8KCGw1KThQlJRmjGCzC1G3gkSoc58bKs0J1azd1A+V7HYPGVZHQ1f8
tltKyKsIy6hSLsBZBSJC0YrNcDtaS3owr1hndDQ96MbYgYyMPZVPH3GcgM8ZMHTr
7G7vEzJ+f8JjTNPK9wTm+g93ZgGESWqhvwIDAQABo0IwQDAOBgNVHQ8BAf8EBAMC
AQYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4EFgQU/o67mbKVJ48GAEU7eVXSaqHw
0xYwDQYJKoZIhvcNAQELBQADggEBABS5A8wRqRUji75UtslG+wPcp/JlatbJN1xu
vCjuGRFGifJnAmz8KHfTXBGwmPc5EjipKC6SocmDYadPZDYgWr4dXSHL3kEOCo6P
bIWyA3dgYGAM1YdAUKiYrKX6Jojo4Bk/M4J/vcMQK3RG37UBvv9fvJpfesHsU36G
35YbFZYnF/cYKr/Uv5TGpDmWhC7QcpiAMs9GwuWc132VknHn3t8ZMq4sDe2lRv/P
CurmByKSvuoRFZiEJNdC4BLeWi9XLKoick9hQHwTwhPBk03qXAHhmtzYVTdv3HMh
5W1qys/clTZD3T2HaQEijKGaLceZ8gPIvwXEaqq+a1niB+Z4I34=
-----END CERTIFICATE-----

"apiVersion: v1\nclusters:\n- cluster:\n    certificate-authority-data: \"LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURJakNDQWdxZ0F3SUJBZ0lVS3NOanZHOWRiYnlWZXUwTCs1ZzJFVkl2d1dvd0RRWUpLb1pJaHZjTkFRRUwKQlFBd0tURVNNQkFHQTFVRUN4TUpSRzlpY25rdGEyOTBNUk13RVFZRFZRUURFd3BMZFdKbGNtNWxkR1Z6TUI0WApEVEl5TURVd05qSXhOREV3TUZvWERUSTNNRFV3TlRJeE5ERXdNRm93S1RFU01CQUdBMVVFQ3hNSlJHOWljbmt0CmEyOTBNUk13RVFZRFZRUURFd3BMZFdKbGNtNWxkR1Z6TUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEEKTUlJQkNnS0NBUUVBcnNDZjZ0NkNRMHd2R1FGUFlQU1oycitmQlh3a3gxT3hLM3kyUHZsdzQ5cFdhZDFYcjhqVQo2Q3NFNVk3NW1iVk14NFhvZHZJZVJQb2ZkVzNlSkVjTnk3Zlo1YUliSFM5dWMyejFGd1czT2IxRlpHUk5TY1E5Cms0Wm9WaVBXb2V3ZEVuTkM2cVhod3V4UTRGUTg2M0REWjRhSVdDaUxmcy9Cc0szTVdRQmJqWDIxYjhCcE14RXgKb1BtcGdhNnJMbThLQ0d3MUtUaFFsSlJtakdDekMxRzNna1NvYzU4YktzMEoxYXpkMUErVjdIWVBHVlpIUTFmOAp0bHRLeUtzSXk2aFNMc0JaQlNKQzBZck5jRHRhUzNvd3IxaG5kRFE5Nk1iWWdZeU1QWlZQSDNHY2dNOFpNSFRyCjdHN3ZFekorZjhKalROUEs5d1RtK2c5M1pnR0VTV3FodndJREFRQUJvMEl3UURBT0JnTlZIUThCQWY4RUJBTUMKQVFZd0R3WURWUjBUQVFIL0JBVXdBd0VCL3pBZEJnTlZIUTRFRmdRVS9vNjdtYktWSjQ4R0FFVTdlVlhTYXFIdwoweFl3RFFZSktvWklodmNOQVFFTEJRQURnZ0VCQUJTNUE4d1JxUlVqaTc1VXRzbEcrd1BjcC9KbGF0YkpOMXh1CnZDanVHUkZHaWZKbkFtejhLSGZUWEJHd21QYzVFamlwS0M2U29jbURZYWRQWkRZZ1dyNGRYU0hMM2tFT0NvNlAKYklXeUEzZGdZR0FNMVlkQVVLaVlyS1g2Sm9qbzRCay9NNEovdmNNUUszUkczN1VCdnY5ZnZKcGZlc0hzVTM2RwozNVliRlpZbkYvY1lLci9VdjVUR3BEbVdoQzdRY3BpQU1zOUd3dVdjMTMyVmtuSG4zdDhaTXE0c0RlMmxSdi9QCkN1cm1CeUtTdnVvUkZaaUVKTmRDNEJMZVdpOVhMS29pY2s5aFFId1R3aFBCazAzcVhBSGhtdHpZVlRkdjNITWgKNVcxcXlzL2NsVFpEM1QySGFRRWlqS0dhTGNlWjhnUEl2d1hFYXFxK2ExbmlCK1o0STM0PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0t\"\n    server: https://51.250.4.42:6443\nname: \"\"\ncontexts: null\ncurrent-context: \"\"\nkind: Config\npreferences: {}\nusers: null\n"


base64_encoded_ca="$(base64 -w0 /pki/ca/root-ca.pem)"

for namespace in $(kubectl get ns --no-headers | awk '{print $1}'); do
    for token in $(kubectl get secrets --namespace "$namespace" --field-selector type=kubernetes.io/service-account-token -o name); do
        kubectl get $token --namespace "$namespace" -o yaml | \
          /bin/sed "s/\(ca.crt:\).*/\1 ${base64_encoded_ca}/" | \
          kubectl apply -f -
    done
done