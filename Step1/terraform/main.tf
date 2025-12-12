# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rgc" {
  name     = "myTFResourceGroup2"
  location = "swedencentral"
}

# Creating a storage account within the resourcegroup
resource "azurerm_storage_account" "sac" {
  name                     = "storaccmessoai"
  resource_group_name      = azurerm_resource_group.rgc.name
  location                 = azurerm_resource_group.rgc.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  static_website {
    index_document     = "resume.html"
  }
}

//resource "azurerm_storage_account_static_website" "example" {
//  storage_account_id = azurerm_storage_account.sac.id
// index_document     = "resume.html"
//}