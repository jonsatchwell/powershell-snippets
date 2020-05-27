$login = Get-AzContext
if ($login -eq $null -or $subSelect -eq $null) {
    if ($login -eq $null) {
        Login-AzAccount | Out-Null
    }

    if ($subSelect -eq $null) {
        $subscriptions = Get-AzSubscription
        $cnt = 1
        Write-Host "ID    Subscription Name"
        Write-Host "-----------------------"

        foreach ($sub in $subscriptions) {
            Write-Host "$cnt   $($sub.name)"
            $cnt++
        }
        $selection = Read-Host -Prompt "Select a subscription to deploy to"
        $subSelect = $subscriptions[$selection - 1] # Revert 1-index to 0-index
    }
    Select-AzSubscription $subSelect.SubscriptionId
    Write-Host ""
}