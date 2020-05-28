# The following script can retrieve options for serice principal credentials from a sinlge key vault. Each secret will be listed to choose from as a login
# Make sure that your main Azure identity, the one you log in to Azure with first using Connect-AZAccount, has read-write permission on the kv.
# The SP creds need to be stored as a single secret using the following json structure.  See setup-sp.ps1 to create the SP and get the json
# # SP credentials structure
# {
#     "clientId": "xxxxxxxxx-de6f-4d16-933f-xxxxxxxxx",
#     "displayName": "AzOps",
#     "name": "xxxxxxxxx-de6f-4d16-933f-xxxxxxxxx",
#     "clientSecret": "xxxxxxxxx-yyyyyy-xxxxxxxxx-zzzzz",
#     "tenantId": "xxxxxxxxx-722d-4429-b82e-xxxxxxxxx",
#     "subscriptionId": "xxxxxx-b647-4299-9014-xxxxxxxx"
#   }
 
#Connect to Azure as your main identity
Clear-AzContext
Connect-AzAccount

# Use a service principal available to you from a key vault
$selection = Read-Host -Prompt "Login with Service Principal? 1=yes"
$selection=1
if ($selection -eq 1) {
    $kvname = 'management-kv'  
    Write-Host "-----------------------"
    $message = "reading secrets from key vault {0}" -f $kvname 
    Write-Host $message
    $secrets = Get-AzKeyVaultSecret $kvname
    $cnt = 1
    foreach($secret in $secrets)
    {
        $name = "$cnt - {0}" -f $secret.Name
        Write-Host $name
        $cnt++             
    }
    $selection = Read-Host -Prompt "Select a Service Principal to connect with"
    $secretSelect = $secrets[$selection - 1]

    Write-Host "Retrieving credentials for $secretSelect.Name"
    $secret = Get-AzKeyVaultSecret $kvname -Name $secretSelect.Name
    $credObj = $secret.SecretValueText | ConvertFrom-Json
    
    Clear-AzContext -Force
    $secureStringPwd = $credObj.clientSecret | ConvertTo-SecureString -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $credObj.clientId, $secureStringPwd
    Write-Host "Logging in to Azure as $secretSelect.Name"
    Connect-AzAccount -TenantId $credObj.tenantId -ServicePrincipal -Credential $cred

}