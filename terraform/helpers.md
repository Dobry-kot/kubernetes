#### SSL
openssl s_server  -accept 8443 -cert /etc/kubernetes/pki/certs/etcd/system\:etcd-server.pem  -key /etc/kubernetes/pki/certs/etcd/system\:etcd-server-key.pem  -CAfile /etc/kubernetes/pki/ca/etcd-ca.pem

openssl s_client -connect PCA:8443 -cert ./client.crt -key ./client.key -verify on -verify_return_error 
openssl s_server  -accept 8443