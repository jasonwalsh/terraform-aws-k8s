output message {
  value = <<EOF

To connect to the Kubernetes dashboard

1. Retrieve an authentication token for the eks-admin service account. Copy the <authentication_token> value from the output. You use this token to connect to the dashboard.

    kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')

2. Start the kubectl proxy.

    kubectl proxy

3. To access the dashboard endpoint, open the following link with a web browser: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login

4. Choose Token, paste the <authentication_token> output from the previous command into the Token field, and choose SIGN IN.
EOF
}
