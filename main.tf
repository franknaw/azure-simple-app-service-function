/*
Create storage account to contain the function code
  An Azure storage account contains all of your Azure Storage data objects, including blobs, file shares, queues, tables, and disks. 
  The storage account provides a unique namespace for your Azure Storage data that's accessible from anywhere in the world over HTTP or HTTPS
  See: https://docs.microsoft.com/en-us/azure/storage/common/storage-account-overview
*/
resource "azurerm_storage_account" "storage_account" {
  name                     = "safranknaw1"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = merge({
    Name = "${var.product_name}-${var.plan_os_type}-storage-account",
    },
    var.tags
  )
}

/*
Create windows app function using dotnet to run a C# function
  Azure Function is a serverless compute service that enables user to run event-triggered code without having to provision or manage infrastructure. 
  Being as a trigger-based service, it runs a script or piece of code in response to a variety of events.
  See: https://docs.microsoft.com/en-us/azure/azure-functions/functions-get-started?pivots=programming-language-csharp
*/
resource "azurerm_windows_function_app" "function_app" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = var.service_plan.id

  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key

  site_config {
    application_stack {
      dotnet_version = "6"
    }
  }

  tags = merge({
    Name = "${var.product_name}-${var.plan_os_type}-app-function",
    },
    var.tags
  )

}

/*
Create an app function with a HTTP trigger binding
  A function that will be run whenever it receives an HTTP request, responding based on data in the body or query string
  See: https://docs.microsoft.com/en-us/azure/azure-functions/functions-triggers-bindings?tabs=csharp
*/
resource "azurerm_function_app_function" "function_app_function" {
  name            = "function-${var.app_name}"
  function_app_id = azurerm_windows_function_app.function_app.id
  language        = "CSharp"


  file {
    name    = "run.csx"
    content = file("../../azure-simple-app-service-function/function/run.csx")
  }

  test_data = jsonencode({
    "name" = "Foo"
  })

  config_json = jsonencode({
    "bindings" = [
      {
        "authLevel" = "function"
        "direction" = "in"
        "methods" = [
          "get",
          "post",
        ]
        "name" = "req"
        "type" = "httpTrigger"
      },
      {
        "direction" = "out"
        "name"      = "$return"
        "type"      = "http"
      },
    ]
  })
}


## Work in progress
# resource "azurerm_windows_function_app_slot" "function_app_function_slot" {
#   name            = "function-slot-${var.app_name}"
#   function_app_id = azurerm_windows_function_app.function_app.id

#   storage_account_name       = azurerm_storage_account.storage_account.name
#   storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key


#   site_config {
#     application_stack {
#       dotnet_version = "6"
#     }
#   }

# }

# resource "azurerm_function_app_function" "function_app_function_staging" {
#   name            = "function-stage-${var.app_name}"
#   function_app_id = azurerm_windows_function_app_slot.function_app_function_slot.id
#   language        = "CSharp"


#   file {
#     name    = "run_stage.csx"
#     content = file("../azure-simple-app-service-function/function/run_stage.csx")
#   }

#   test_data = jsonencode({
#     "name" = "Foo"
#   })

#   config_json = jsonencode({
#     "bindings" = [
#       {
#         "authLevel" = "function"
#         "direction" = "in"
#         "methods" = [
#           "get",
#           "post",
#         ]
#         "name" = "req"
#         "type" = "httpTrigger"
#       },
#       {
#         "direction" = "out"
#         "name"      = "$return"
#         "type"      = "http"
#       },
#     ]
#   })
# }
