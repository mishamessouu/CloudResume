# The terraform to handle the Frontdoor setup (CDN, Load Balancer)

## NOTE When below is done:
/* 
At least the first time, you need to update the nameservers for your domain to point to Azure Frontdoor.
*/

resource "azurerm_cdn_frontdoor_profile" "fd" {
  name                = "fd-messoai"
  resource_group_name = azurerm_resource_group.rgc.name
  sku_name            = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_endpoint" "fd_endpoint" {
  name                     = "fd-messoai-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
}

resource "azurerm_cdn_frontdoor_origin_group" "fd_origin_group" {
  name                     = "fd-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {

    protocol            = "Https"
    path                = "/"
    interval_in_seconds = 100
  }
}

resource "azurerm_cdn_frontdoor_origin" "fd_origin" {
  name                          = "storage-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group.id

  host_name = trimsuffix(
    replace(azurerm_storage_account.sac.primary_web_endpoint, "https://", ""),
    "/"
  )

  origin_host_header = trimsuffix(
    replace(azurerm_storage_account.sac.primary_web_endpoint, "https://", ""),
    "/"
  )

  http_port  = 80
  https_port = 443
  certificate_name_check_enabled = false
}


resource "azurerm_cdn_frontdoor_route" "fd_route" {
  name                          = "fd-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.fd_endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.fd_origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.fd_origin.id]

  supported_protocols    = ["Http", "Https"]
  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true

  patterns_to_match      = ["/*"]
  link_to_default_domain = true
}

resource "azurerm_cdn_frontdoor_custom_domain" "messoai_domain" {
  name                     = "messoai-domain"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.fd.id
  host_name                = "www.messo.ai"

  tls {
    certificate_type    = "ManagedCertificate"
  }
}

resource "azurerm_cdn_frontdoor_custom_domain_association" "domain_association" {
  cdn_frontdoor_custom_domain_id = azurerm_cdn_frontdoor_custom_domain.messoai_domain.id
  cdn_frontdoor_route_ids        = [azurerm_cdn_frontdoor_route.fd_route.id]
}

output "frontdoor_url" {
  value = "https://${azurerm_cdn_frontdoor_endpoint.fd_endpoint.host_name}"
}


