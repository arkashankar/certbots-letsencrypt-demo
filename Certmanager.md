cert-manager (main controller)

This is the core component that does the actual work. Think of it as the "brain" of the operation. It constantly watches your Kubernetes cluster for certificate requests (called Certificate resources). When it sees a new request, it communicates with certificate authorities like Let's Encrypt to obtain and renew certificates. It also handles installing these certificates into the right places and automatically renews them before they expire - like having an assistant who never forgets to renew your IDs before they become invalid.

cert-manager-cainjector (CA injector)

This component has a specific but important job: it injects CA (Certificate Authority) certificates into various Kubernetes resources. When Cert Manager creates certificates for securing communication between components (like for the webhook below), the cainjector ensures these trusted root certificates are properly distributed. It's like a specialized courier whose only job is to deliver the master "seals of approval" to different departments so they can trust each other's documents.

cert-manager-webhook (admission webhook)

This acts as a "validator" or "quality checker" for certificate requests. When you or another application tries to create or modify certificate resources, the webhook intercepts these requests before they're processed. It checks if the requests are properly formatted, valid, and secure. This prevents mistakes and ensures only legitimate certificate requests go through - similar to having a receptionist who checks all incoming paperwork for errors before passing it to the main office.

How they work together: When you request a certificate, the webhook first validates your request. The main controller then processes it and obtains the certificate. The cainjector makes sure all the necessary trust certificates are in place so different components can securely communicate. All three work in harmony to automate what would otherwise be complex, manual SSL/TLS certificate management.

Install ingress-controller
kubectl create ns ingress-nginx

kubectl -n ingress-nginx apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.41.2/deploy/static/provider/cloud/deploy.yaml

kubectl -n ingress-nginx get pods

kubectl -n ingress-nginx --address 0.0.0.0 port-forward svc/ingress-nginx-controller 80
kubectl -n ingress-nginx --address 0.0.0.0 port-forward svc/ingress-nginx-controller 443

PROBLEM FIX -
TO access the application from kind we cannot directly hit EC2
ip address we need to do IP_FORWADING
Get KIND IP

KIND_NODE_IP=$(docker inspect devcluster-control-plane | grep IPAddress | head -1 | awk '{print $2}' | tr -d '",')
echo $KIND_NODE_IP  

sudo iptables -t nat -A PREROUTING -p tcp --dport 30080 -j DNAT --to-destination 172.18.0.2:30080
sudo iptables -A FORWARD -p tcp -d 172.18.0.2 --dport 30080 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -p tcp -d 172.18.0.2 --dport 30080 -j MASQUERADE
------------------------------------------------------------------------

Better Approach -

Internet (Let's Encrypt)
        |
        | HTTP-01 (port 80)
        v
EC2 Public IP :80 / :443
        |
KIND (extraPortMappings)
        |
NGINX Ingress Controller
        |
Demo App (Service)


1. **STEP01 - Install Cert-manager**

a. create namespace
kubectl create namespace cert-manager
b. Install cert-manager (CRDs + Controllers)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml

c. verify 
kubectl get pods -n cert-manager

2. **Create Let's Encrypt ClusterIssuer**
kubectl apply -f clusterissuer-staging.yaml

verify
kubectl get clusterissuer

3. **Deploy app and services**
kubectl apply -f demo-deployment.yaml

kubectl apply -f demo-service.yaml

4. **Create Ingress with TLS (cert-manager trigger)**
kubectl apply -f demo-ingress.yaml

5. **Watch Certificate Issuance**
kubectl logs -n cert-manager deploy/cert-manager -f

kubectl get certificate
kubectl get challenge
kubectl get order


kubectl get secret demo-app-tls

