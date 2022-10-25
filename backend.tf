terraform {
  backend "azurerm" {
    resource_group_name  = "TerraFproj4"
    storage_account_name = "terrafstoragep4"
    container_name       = "terrafcontainerp4"
    key                  = "terraform.tfstate"
  }
}
