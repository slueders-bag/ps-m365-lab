

Connect-AzureAD
Install-Module microsoft.graph.users,microsoft.graph.authentication -Scope CurrentUser -Force

# set usageLocation to country
$all = Get-AzureADUser -all $true
$all | Where-Object{$_.country -like ""} |  Set-AzureADUser -Country "Switzerland" -Verbose
Get-AzureADUser |Format-Table -AutoSize displayname,country,usageLocation

$all | ForEach-Object-Object {
      
    $c = $_.country
    switch ($c) {
        "United States" { $usageLoc = "US" }
        "Egypt" {$usageLoc = "EG"}
        Default {$usageLoc = "CH"}
    }
    Set-AzureADUser -ObjectId $_.objectid -UsageLocation $usageLoc -Verbose
}

 Get-AzureADUser | Format-Tablermat-Table -AutoSize displayname,country,usageLocation

#objects
(get-date).ToUniversalTime()
 $d = New-Object -TypeName System.DateTime
([System.DateTime])::UtcNow

$employee = New-Object -TypeName PSCustomObject -Property @{
    Name = "SLU"
    Title = "Consultant"
}

#Azure Invite & Filter Guests
Get-Command *invit* -Module AzureAD
New-AzureADMSInvitation -InvitedUserDisplayName "SLU (Baggenstos)" -SendInvitationMessage $true -InvitedUserEmailAddress slueders@baggenstos -InviteRedirectUrl https://myapps.microsoft.com –Verbose
Get-AzureADUser -All $True -Filter "usertype eq 'Guest'"
Get-AzureADUser -All $True | Where-Object {$_.UserType -ne 'Member’}

Get-AzureADDirectoryRole
Add-AzureADDirectoryRoleMember -ObjectId a9fa5605-f7fe-4449-ba13-2867284c521c -RefObjectId 22035296-2a44-4671-90c4-7b1a7ceba2dd
Get-AzureADDirectoryRoleMember -ObjectId a9fa5605-f7fe-4449-ba13-2867284c521c
Get-AzureADDirectoryRoleMember -ObjectId a9fa5605-f7fe-4449-ba13-2867284c521c |Where-Object{$_.displayname -notlike "mod*" -and $_.displayname -notlike "micro*" -and $_.displayname -notlike "slu*"} | ForEach-Object{Remove-AzureADDirectoryRoleMember -ObjectId  a9fa5605-f7fe-4449-ba13-2867284c521c -MemberId $_.objectid -Verbose}
