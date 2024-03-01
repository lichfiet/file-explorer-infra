# file-explorer-infra

This is the backend for the file explorer project, a full setup guide will exist in the [lichfiet/file-explorer-web](https://github.com/lichfiet/file-explorer-web) repository soon, but this will walk you through how to set up your AWS services with Terraform.

## How to use

### Requirements:

- Terraform
  - [Installation Link](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) 
- AWS Account
- A can-do attitude

### Getting Started:

1. Clone the github repository and initialize terraform

    ```
    git clone https://github.com/lichfiet/file-explorer-infra.git &&
    cd file-explorer-infra &&
    terraform init
    ```

2. Modify the .env.sample file

    Change the file name with `mv .env.sample .env` and then you will need an AWS IAM User's Access Key and Secret Key. Information on how to obtain in step 3. In the `.env` file, replace the `YOUR AWS ACCESS KEY` with your AWS IAM User's Acess Key, and replace the `YOUR AWS SECRET ACCESS KEY` with your secret key.

    *(Ex.)*
    ```
    AWS_ACCESS_KEY_ID=123456789
    AWS_SECRET_ACCESS_KEY=1a2b3c4d5e6f7g
    ```

3. Creatting IAM Credentials *(Skip if you do not need to make them)*


4. Deploy your resources

    Run `terraform apply` to build your infrastructure