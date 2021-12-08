
import-module azuread

# azure ad
Connect-AzureAD

# count all user accounts
Get-Command -Module azuread -noun azureaduser
Get-AzureADUser -All $true | Measure-Object
$all = Get-AzureADUser -All $true
$all | Get-Member
$all.city

# sort / group department