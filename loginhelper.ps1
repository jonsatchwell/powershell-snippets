Clear-AzContext
Connect-AzAccount

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