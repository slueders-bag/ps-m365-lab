
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
Get-AzureADUser -All $true | Select-Object department -Unique
$all.department | Select-Object -Unique
$all | Group-Object department 

# user without department
$all | Group-Object department | select -ExpandProperty Group -First 1
$all | sort department | ft -AutoSize department,displayname 
$all | Where-Object{$PSItem.department -notlike ""}
$all | Where-Object{$PSItem.department -ne $null -and $_.country -like "Unit*"}

# Filter parameter
Get-AzureADUser -Filter "country eq 'United States'"
Get-AzureADUser -Filter "startswith(country,'unit')"

$alias = $all.userprincipalname -replace ("@M365x682019.OnMicrosoft.com","")
SMTP:vorname.nachname@contoso.com

$all | ForEach-Object{
        $pre = "SMTP:" + $_.displayname -replace (" ",".")
        $pre + "@" +(Get-AzureADDomain).Name
    }




