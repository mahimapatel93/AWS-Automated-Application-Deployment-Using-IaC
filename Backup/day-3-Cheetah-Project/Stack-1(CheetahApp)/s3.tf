module "s3" {
source = "./localmodules/s3-buckets"
env_name = "dev"
}