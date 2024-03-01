# file-explorer-infra

This is the backend for the file explorer project, a full setup guide will exist in the [lichfiet/file-explorer-web](https://github.com/lichfiet/file-explorer-web) repository soon, but this will walk you through how to set up your AWS services with Terraform.

## How to use

### Requirements:

- Terraform
  - [Installation Link](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) 
- AWS Account
- A can-do attitude

### Getting Started:

1. #### Clone the github repository and initialize terraform

    ```
    git clone https://github.com/lichfiet/file-explorer-infra.git &&
    cd file-explorer-infra &&
    terraform init
    ```

2. #### Creating IAM Credentials *(Skip if you do not need to make them)*

    1. Go to the IAM Service in AWS
    2. Select **Users** and then **Create New**
    3. Enter a user name and click **Next**
    4. Select "Attach Policies Directly" and then click **Next**
    5. Add the "Administrator Access" policy and click **Next**
    6. Click **Create User**

    Then, once you are back in the IAM user list:
    
    1. Select **Users**
    2. Select the user you just created
    3. Click the "Create Access Key" hyperlink.

    Then copy this information and paste it into your `.env` file

3. #### Modify the .env.sample file

    Change the file name with `mv .env.sample .env` and then you will need an AWS Admin IAM User's Access Key and Secret Key.
    
    In the `.env` file, replace the `YOUR AWS ACCESS KEY` with your AWS IAM User's Acess Key, and replace the `YOUR AWS SECRET ACCESS KEY` with your secret key.

    *(Ex. `.env` file)*
    ```
    AWS_ACCESS_KEY_ID=123456789
    AWS_SECRET_ACCESS_KEY=1a2b3c4d5e6f7g
    ```

4. #### Deploy your resources

    Run `terraform apply` to build your infrastructure