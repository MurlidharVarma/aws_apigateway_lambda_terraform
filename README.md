# Provision AWS API Gateway with Lambda Integration using Terraform

## 1. initialize the terraform 
```
terraform init
```

## 2. Create terraform workspace for east region
```
terraform workspace new east
terrform workspace list
terraform workspace select east
```

## 3. Create tfvar file specific to us-east-1 region and apply
```
terraform apply --var-file us-east-1.tfvars --auto-approve
```

### Sample tfvar file (say us-east-1.tfvars) would look like
```terraform
aws_region="us-east-1"

domain="example.com"
subdomain ="aws-east"

api_name="example-api"
stage_name="v1"

client_id="my_cognito_client_id"
cognito_user_pool_arn = "arn:aws:cognito-idp:us-east-1:xxx:userpool/us-east-1_ABCD"
```

## 4. Create terraform workspace for west region
```
terraform workspace new west
terrform workspace list
terraform workspace select west
```

## 5. Create tfvar file specific to us-west-2 region and apply
```
terraform apply --var-file us-wesr-2.tfvars --auto-approve
```

### Sample tfvar file (say us-west-2.tfvars) would look like
```terraform
aws_region="us-west-2"

domain="example.com"
subdomain ="aws-west"

api_name="example-api"
stage_name="v1"

client_id="my_cognito_client_id"
cognito_user_pool_arn = "arn:aws:cognito-idp:us-east-1:xxx:userpool/us-east-1_ABCD"
```

## You should now have API GW running in 2 regions backed by respective independent domain
>aws-east.example.com

>aws-west.example.com

### Please refer to api_spec.yaml for api endpoints
