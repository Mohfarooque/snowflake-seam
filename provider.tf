terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87"
    }
  }
}

provider "snowflake" {
  role = "SYSADMIN"
}

provider "snowflake" {
  role  = "SECURITYADMIN"
  alias = "securityadmin"

}
provider "snowflake" {
  role  = "ACCOUNTADMIN"
  alias = "accountadmin"

}

provider "aws" {
}
