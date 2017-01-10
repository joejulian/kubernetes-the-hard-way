This terraform plan can be used to complete the [JPC Infrastructure](/docs/01-infrastructure-jpc.md) step. 

# Usage

Add your credentials to `credentials.tf`.
Add the id for your `kubernetes` network to `network.tf` from `triton network get kubernetes`.

```
terraform get
terraform apply
```
