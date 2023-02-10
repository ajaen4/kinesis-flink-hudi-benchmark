# Kinesis Flink App Hudi Benchmark

AWS Kinesis Flink App processing a real time streaming input that writes the output in different file formats to S3

## Architecture

![Alt text](images/flink-hudi.png?raw=true "Architecture")

## Pre-requisites - Local Testing

Include the secret and access key within a profile called `practica-hudi-flink` as the provider and the backend point to it to obtain the credentials while accesing from the CLI
