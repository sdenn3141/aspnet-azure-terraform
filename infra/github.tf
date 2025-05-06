locals {
  repository_name = "aspnet-azure-terraform"
}

resource "github_actions_secret" "web_app_name" {
  repository      = local.repository_name
  secret_name     = "WEB_APP_NAME"
  plaintext_value = azurerm_windows_web_app.example.name
}

resource "github_actions_secret" "kudu_username" {
  repository      = local.repository_name
  secret_name     = "KUDU_USERNAME"
  plaintext_value = azurerm_windows_web_app.example.site_credential.0.name
}

resource "github_actions_secret" "kudu_password" {
  repository      = local.repository_name
  secret_name     = "KUDU_PASSWORD"
  plaintext_value = azurerm_windows_web_app.example.site_credential.0.password
}
