# simpleinfra

Simple terraform scripting for standing up resources
Basic requirements to run this terraform script manually.
Terraform and AZ CLI are required


#** REQUIRED STEPS**
1. Clone this repo
2. Terraform init
3. Az login ( contributor credentials )
4. Modify either staging.tfvars or production.tfvars 
5. ./standup.sh  staging                  # use the name of the previously modified tfvars files


# to destroy those resources 
./teardown.sh staging


