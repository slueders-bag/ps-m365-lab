#---------------------------------------------------------[Initialisations]--------------------------------------------------------

if(Get-InstalledModule -Name "AzureAD"){Connect-AzureAd}
else {Install-Module AzureAD -Scope CurrentUser -Confirm:$false}

if(Get-InstalledModule -Name "ImportExcel"){Import-Module ImportExcel}
else {Install-Module ImportExcel -Scope CurrentUser -Confirm:$false}


#----------------------------------------------------------[Declarations]----------------------------------------------------------

$tenantName = (Get-AzureADTenantDetail).Displayname
$tenant = (Get-AzureADDomain | Where-Object{$_.isinitial -eq $true}).name
$reportPath = "C:\temp\" + ((get-date -format d) -replace "/","-") + "_" + $tenant 

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#-----------------------------------------------------------[Execution]------------------------------------------------------------

# get all licensed users
$all = Get-AzureADUser -All $true | Where-Object{$_.AssignedLicenses -ne $null}

#Downloads https://download.microsoft.com/download/e/3/e/e3e9faf2-f28b-490a-9ada-c6089a1fc5b0/Product%20names%20and%20service%20plan%20identifiers%20for%20licensing.csv
$csvDownload = Invoke-WebRequest -Uri https://download.microsoft.com/download/e/3/e/e3e9faf2-f28b-490a-9ada-c6089a1fc5b0/Product%20names%20and%20service%20plan%20identifiers%20for%20licensing.csv -ContentType csv
$csv = ConvertFrom-Csv -InputObject $csvDownload

[System.Collections.ArrayList]$report = @()

foreach ($user in $all)
        {

            [System.Collections.ArrayList]$licenseDetails = @()
            [System.Collections.ArrayList]$disPlanDetails = @()

            $licenses = $user.AssignedLicenses.skuid
            [array]$disabledPlans = $user.AssignedLicenses.DisabledPlans -split " "

            foreach ($license in $licenses){
                $licObj = Get-AzureADSubscribedSku | Where-Object{$_.SKUid -eq $license}      
                $ind = $csv.'String_ Id'.IndexOf($licObj.skupartnumber)
                $licName = $csv[$ind]
                $licDispName = $licName.Product_Display_Name
                $licenseDetails.Add($licDispName)
            }

            foreach ($disabledPlan in $disabledPlans){      
                $ind = $csv.'Service_Plan_Id'.IndexOf($disabledPlan)
                $disPlanObj = $csv[$ind]
                $disPlanName = $disPlanObj.Service_Plans_Included_Friendly_Names
                $disPlanDetails.Add($disPlanName)   
            }

            $disPlanDetails = $disPlanDetails | Sort-Object
            $licenseDetails = $licenseDetails | Sort-Object

            $ReportLine = [PSCustomObject][Ordered]@{  
                   User            = $User.DisplayName
                   UPN             = $User.UserPrincipalName
                   Country         = $User.Country
                   Department      = $User.Department
                   Title           = $User.JobTitle
                   Licenses        = $licenseDetails -join ";"
                   DisabledPlans   = $disPlanDetails -join ";" }
            
            $report.Add($ReportLine)
  
        }

#reporting            
$report | Out-GridView
$report | ConvertTo-Html -Title "Microsoft 365 License Report"  -As Table | Out-File ($reportPath + ".htm")
$report | Export-Excel -Path ($reportPath + ".xlsx") -Title ("Microsoft 365 License Report " + $tenantName) -Show

Write-Host "`n***********************************************************************`nReports exported to"$reportPath -ForegroundColor Green

#https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-ps-examples
