# Create the Service Principal
$servicePrincipal = New-AzADServicePrincipal -Role Owner -Scope / -DisplayName AzOps
$StandardString = ConvertFrom-SecureString $servicePrincipal.Secret -AsPlainText 

$creds = [ordered]@{
    clientId       = $servicePrincipal.ApplicationId
    displayName    = $servicePrincipal.DisplayName
    name           = $servicePrincipal.ServicePrincipalNames[1]
    clientSecret   = [System.Net.NetworkCredential]::new("", $servicePrincipal.Secret).Password
    tenantId       = (Get-AzContext).Tenant.Id
    subscriptionId = (Get-AzContext).Subscription.Id
}
$creds | ConvertTo-Json

# Output will be as follows 
# {
#     "clientId": "xxxxxxxxx-de6f-4d16-933f-xxxxxxxxx",
#     "displayName": "AzOps",
#     "name": "xxxxxxxxx-de6f-4d16-933f-xxxxxxxxx",
#     "clientSecret": "xxxxxxxxx-yyyyyy-xxxxxxxxx-zzzzz",
#     "tenantId": "xxxxxxxxx-722d-4429-b82e-xxxxxxxxx",
#     "subscriptionId": "xxxxxx-b647-4299-9014-xxxxxxxx"
#   }







