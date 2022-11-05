# How to start using terraform with s3 backend

1. Change aws region and bucket name to what you need.

- Open `./main.tf`
- Change `aws-region` in `locals` to the region you want
- Change `terraform_state_bucket_name` to the bucket name that makes sense for your project. **Bucket name must be unique across all of AWS**
- Change `region` and `bucket` in `backend` configuration a few lines above to match the values you just set in `locals`. Keep backend configuration commented out for now

2. Terraform init for the first time

```
terraform init
```

3. Terraform apply to create s3 bucket, dynamodb table and a secret in KMS for encypting data in s3

```
terraform apply

-> Do you want to perform these actions?
yes
```

4.  Uncomment the s3 backend provider code, cause now we created all infrastructure to be able to switch to new backend

5.  Terraform init once again cause we're using new backend

```
terraform init

-> Do you want to copy existing state to the new backend?
yes
```

6. Just as a test, do terraform apply and see 0 changes

```
terraform apply
```

# How to destroy the infrastructure (s3 + dynamodb) without messing things up

1. Comment out the backend configuration in `./main.tf`

2. Move state from s3 backend to local backend

```
terraform init -migrate-state

-> Do you want to copy existing state to the new backend?
yes
```

3. Make the s3 bucket that stores state as destroyable

In `./backend/main.tf` change `prevent_destroy = true` to `prevent_destroy = false` in s3 bucket resource

4. Delete all content of all versions in the bucket.

You have 2 options:

a) via AWS console, go to s3, select the bucket and click `EMPTY BUCKET`

b) via AWS CLI:

Run the command after
**replacing `<YOUR BUCKET NAME>` with your bucket name in 2 places**.

```
aws s3api delete-objects --bucket <YOUR BUCKET NAME> \
  --delete "$(aws s3api list-object-versions \
  --bucket "<YOUR BUCKET NAME>" \
  --output=json \
  --query='{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"
```

5. Run terraform destroy

```
terraform destroy

-> Do you really want to destroy all resources?
yes
```
