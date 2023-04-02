
provider "aws" {
    access_key = "AKIAQZ6VREOSUOSWJ6WT"
    secret_key = "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"
    region = "us-east-1"
}
resource "aws_s3_bucket" "onebucket" {
   bucket = "noelie1234567labakenk"
   acl = "private"
   versioning {
      enabled = true
   }
   tags = {
     Name = "Bucket1"
     Environment = "Test"
   }
}