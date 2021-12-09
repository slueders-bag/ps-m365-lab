$all = Get-AzureADUser -All $true | ?{$_.AssignedLicenses -ne $null}
$sku = Get-AzureADSubscribedSku
$csv = Import-Csv "C:\temp\Product names and service plan identifiers for licensing.csv"
#https://download.microsoft.com/download/e/3/e/e3e9faf2-f28b-490a-9ada-c6089a1fc5b0/Product%20names%20and%20service%20plan%20identifiers%20for%20licensing.csv

$licenseDetails = @()
$disPlanDetails = @()
$report = @()

foreach ($user in $all)
        {
            $licenses = $user.AssignedLicenses.skuid
            [array]$disabledPlans = $user.AssignedLicenses.DisabledPlans -split " "

            foreach ($license in $licenses){
                $licObj = Get-AzureADSubscribedSku | ?{$_.SKUid -eq $license}      
                $ind = $csv.'String_ Id'.IndexOf($licObj.skupartnumber)
                $licName = $csv[$ind]
                $licDispName = $licName.Product_Display_Name
                $licenseDetails += $licDispName
            }

            foreach ($disabledPlan in $disabledPlans){      
                $ind = $csv.'Service_Plan_Id'.IndexOf($disabledPlan)
                $disPlanObj = $csv[$ind]
                $disPlanName = $disPlanObj.Service_Plans_Included_Friendly_Names
                $disPlanDetails += $disPlanName
            }

            [string]$disPlanDetails = $disPlanDetails -join ", " 
            [string]$licenseDetails = $licenseDetails -join ", "

            $ReportLine = [PSCustomObject][Ordered]@{  
                   User            = $User.DisplayName
                   UPN             = $User.UserPrincipalName
                   Country         = $User.Country
                   Department      = $User.Department
                   Title           = $User.JobTitle
                   Licenses        = $licenseDetails
                   DisabledPlans = $disPlanDetails }
            
            $Report += ($ReportLine)
  
        }

            
$report | Out-GridView

#https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-ps-examples