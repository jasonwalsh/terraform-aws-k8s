## Contents

- [Requirements](#requirements)
- [Usage](#usage)
- [Guestbook Application](#guestbook-application)

## Requirements

- [`kubectl`](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [`aws-iam-authenticator`](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html)
- [`AWS CLI`](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [`jq`](https://stedolan.github.io/jq/)

## Usage

```bash
terraform init
terraform apply
```

If the apply finishes successfully, copy the `kubeconfig` file to `$HOME/.kube`. For more instructions, refer to [this](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/) documentation.

## Guestbook Application

To deploy a simple guestbook application, follow [this](https://docs.aws.amazon.com/eks/latest/userguide/eks-guestbook.html) guide.
