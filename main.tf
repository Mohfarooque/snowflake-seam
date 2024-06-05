locals {
  grants = jsondecode(file("/home/ec2-user/user/grants.json"))
}


resource "snowflake_role" "roles" {
  provider = snowflake.accountadmin
  for_each = { for role in local.grants.snowflake_roles : role.name => role }
  name     = each.value.name
}

# Grant Privileges on Databases

resource "snowflake_grant_privileges_to_account_role" "database_grants" {
  provider          = snowflake.accountadmin
  for_each          = { for grant in local.grants.snowflake_database_grants : "${grant.role}_${grant.database_name}" => grant }
  account_role_name = snowflake_role.roles[each.value.role].name
  privileges        = each.value.privilege
  on_account_object {
    object_type = "DATABASE"
    object_name = each.value.database_name
  }
  always_apply      = true
  with_grant_option = true
}


# Grant Privileges on Schemas

resource "snowflake_grant_privileges_to_account_role" "schema_grants" {
  for_each = { for grant in local.grants.snowflake_schema_grants : "${grant.role}_${grant.database_name}_${grant.schema_name}" => grant }

  account_role_name = snowflake_role.roles[each.value.role].name
  
  on_schema {
    schema_name = "\"${each.value.database_name}\".\"${each.value.schema_name}\""
  }
  
  all_privileges    = true
  with_grant_option = true
}

# Grant Previleges to tables

resource "snowflake_grant_privileges_to_account_role" "example" {
 for_each = { for grant in local.grants.snowflake_table_grants : "${grant.role}_${grant.database_name}_${grant.schema_name}_${grant.table_name}" => grant } 
 privileges        = each.value.privilege
  account_role_name = snowflake_role.roles[each.value.role].name
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = "\"${each.value.database_name}\".\"${each.value.schema_name}\""
    }
  }
}


# Grant USAGE on the database to all roles

resource "snowflake_grant_privileges_to_account_role" "usage_grants" {
  for_each = { for role in local.grants.snowflake_roles : role.name => role }

  account_role_name = snowflake_role.roles[each.key].name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = "network"
  }
  always_apply      = true
  with_grant_option = false
}
