$ErrorActionPreference = "Stop"

$apiBaseUrl = terraform -chdir=infra/terraform output -raw api_base_url

$configContent = @"
window.APP_CONFIG = {
  apiBaseUrl: "$apiBaseUrl",
};
"@

Set-Content -Path "frontend/config.js" -Value $configContent -Encoding UTF8
Write-Host "Updated frontend/config.js with API base URL: $apiBaseUrl"
