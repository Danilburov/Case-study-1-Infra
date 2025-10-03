//file for storing the state of the project and then using it for the pipeline
terraform{
    backend "s3" {
        bucket = "case-study-1-CI/CD-bucket"
        key = "global/infra/terraform.tfstate"
        region = "eu-central-1"
        dynamodb_table = "state-for-case-study-1-CI/CD"
        encrypt = true
    }
}