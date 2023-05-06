# Kinesis Flink App Hudi Benchmark

## Contributors

This repository has been developed primarily by [@ajaen4](https://github.com/ajaen4), [@adrij](https://github.com/adrijh) and [@alfonjerezi](https://github.com/alfonjerezi).

## Introduction

This project deploys an architecture in AWS which ingest and processes streaming data with Kinesis Flink Application and writes the output to S3 in Hudi and JSON format.

## Architecture

![Alt text](images/flink-hudi.png?raw=true "Architecture")

## Documentation

Articles:
 - [First article: LakeHouse Flink streaming](https://www.bluetab.net/en/lakehouse-streaming-en-aws-con-apache-flink-y-hudi/)

## Requirements

- You must own an AWS account and have an Access Key to be able to authenticate. You must create a profile and substitute in all files where "practica_cloud" is present and put the previous credentials in it. These are the files were you need to substitute the previous string:
    - event_generation/.env
    - flink_app/local/.env
    - infra/backend.tf
    - infra/provider.tf
    - infra/bootstraper-terraform/providers.tf

You need this so every script or deployment is done with the correct credentials. See [here](https://docs.aws.amazon.com/cli/latest/reference/configure/) steps to create it.

- Versions:
    - Terraform = 1.1.7
    - hashicorp/aws = 4.54.0
    - Python = 3.8

## Infrastructure deployed

This code will deploy the following infraestructure inside AWS:
- 2 Kinesis Flink Applications
- 1 Kinesis Data Streams
- 1 S3 bucket

## Installation

Follow the instructions [here](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started#:~:text=popular%20package%20managers.-,%C2%BB,Install%20Terraform,-Manual%20installation) to install terraform

Follow the instructions [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) to install the AWS CLI

Follow the instructions [here](https://www.python.org/downloads/release/python-3816/) to install Python 3.8

## bucket and DynamoDB for terraform state deployment

This small infra deployment is to be able to use remote state with Terraform. See more info about remote state [here](https://developer.hashicorp.com/terraform/language/state/remote). Commands:

```bash

cd infra/bootstraper-terraform
terraform init
terraform <plan/apply/destroy> -var-file=vars/bootstraper.tfvars

# Example
cd infra/bootstraper-terraform
terraform init
terraform apply -var-file=vars/bootstraper.tfvars
```

It is important that you choose wisely the variables declared in the "bootstraper-terrafom/vars/bootstraper.tfvars" file because the bucket name is formed using these.

There will be an output printed on the terminal's screen, this could be an example:

```bash
state_bucket_name = "eu-west-1-bluetab-cm-vpc-tfstate"
```

Please copy it, we will be using it in the next chapter.

## Infrastructure deployment

To be able to deploy the infrastructure it's necessary to fill in the variables file ("infra/vars.tfv") and the backend config for the remote state ("terraform.tf")

To deploy, the following commands must be run:

```bash
terraform <plan/apply/destroy> -var-file=vars/flink-hudi.tfvars
```

We will use the value copied in the previous chapter, the state bucket name, to substitute the <OUTPUT_FROM_BOOTSTRAPER_TERRAFORM> value in the infra/backend.tf file.

## Sending events with Locust

Once deployed, you can make use of the provided Locust application to send events to the Kinesis Stream. Just make sure that your AWS profile and Kinesis Stream name are properly configured in ```event_generation/.env``` and run

```bash
cd event_generation
locust --tags send
```

A Locust process will start and you can access its UI in http://0.0.0.0:8089/. You can modify number of users and rate, but the defaults will suffice for testing the application.

## Application details

Some dependencies are needed for the Flink application to work properly which entail some explanation

- `flink-sql-connector-kinesis` - Fundamental connector for our Flink application to be able to read from a Kinesis Stream.
- `flink-s3-fs-hadoop` - Allows the application to operate on top of S3.
- `hudi-flink1.15-bundle` - Package provided by Hudi developers, with all the necessary dependencies to work with the technology.
- `hadoop-mapreduce-client-core` - Additional dependency required for writing to Hudi to work correctly in KDA. It is possible that in future versions of the Hudi Bundle this dependency will not be needed.


## License

MIT License - Copyright (c) 2023 The kinesis-flink-hudi-benchmark Authors.
