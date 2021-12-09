<#
.SYNOPSIS
  <new user from csv>

.DESCRIPTION
  <Brief description of script>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - Example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        <1.0>
  Author:         <SLU>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

import-module AzureAD
Connect-AzureAD

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Declare Variables in this area
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "Password1+"

[string]$report = @()
$company = "SLU Corp"
$report += "<h1>New User Report</h1>"
$report += "<style>
    td {width:100px; max-width:300px; background-color:lightgrey;}
    table {width:100%;border-width: 0px; border-style: solid; border-color: black; border-collapse: collapse; margin-right: auto;}
    th {font-size:12pt;background-color:yellow;text-align: left}
    </style>"


#-----------------------------------------------------------[Functions]------------------------------------------------------------

# Use this area for writing functions
function New-RandomUser {
    <#
        .SYNOPSIS
            Generate random user data 
            from Https://randomuser.me/.
        .DESCRIPTION
            This function uses the free API for generating random user data from https://randomuser.me/
        .EXAMPLE
            Get-RandomUser 10
        .EXAMPLE
            Get-RandomUser -Amount 25 -Nationality us,gb 
        .LINK
            https://randomuser.me/
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [ValidateRange(1,500)]
        [int] $Amount,

        [Parameter()]
        [ValidateSet('Male','Female')]
        [string] $Gender,

        # Supported nationalities: AU, BR, CA, CH, DE, DK, ES, FI, FR, GB, IE, IR, NL, NZ, TR, US
        [Parameter()]
        [string[]] $Nationality,

        [Parameter()]
        [ValidateSet('json','csv','xml')]
        [string] $Format = 'json',

        # Fields to include in the results.
        # Supported values: gender, name, location, email, login, registered, dob, phone, cell, id, picture, nat
        [Parameter()]
        [string[]] $IncludeFields,

        # Fields to exclude from the the results.
        # Supported values: gender, name, location, email, login, registered, dob, phone, cell, id, picture, nat
        [Parameter()]
        [string[]] $ExcludeFields
    )

    $rootUrl = "http://api.randomuser.me/?format=$($Format)"

    if ($Amount) {
        $rootUrl += "&results=$($Amount)"
    }

    if ($Gender) {
        $rootUrl += "&gender=$($Gender)"
    }

    if ($Nationality) {
        $rootUrl += "&nat=$($Nationality -join ',')"
    }

    if ($IncludeFields) {
        $rootUrl += "&inc=$($IncludeFields -join ',')"
    }

    if ($ExcludeFields) {
        $rootUrl += "&exc=$($ExcludeFields -join ',')"
    }
    Invoke-RestMethod -Uri $rootUrl
}

function Send-ReportbyMail ($credentials, $To, $From, $subject, $body)
{
    Send-MailMessage -To $To -from $From -Subject $subject -Body $body -BodyAsHtml -smtpserver smtp.office365.com -usessl -Credential $credentials -Port 587 
    Write-host "Report sent to: $to" -ForegroundColor Green
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------

#CSV
$usr = New-RandomUser -Amount 10 -Nationality ch,de -Format csv

#JSON
#$us = New-RandomUser -Amount 10 -Nationality ch,de -Format json

#convert to PS Object 
$userObj = ConvertFrom-Csv -InputObject $usr

#foreach objects
$userObj | ForEach-Object{
    
    $upn = $_.email -replace "example.com","M365x682019.onmicrosoft.com"

    $newUser = New-AzureADUser -AccountEnabled $true `
                    -Country $_.'location.country'                        `
                    -City $_.'location.city'                       `
                    -CompanyName $Company                        `
                    -GivenName $_.'name.first'                       `
                    -DisplayName ($_.'name.first' + " " + $_.'name.last')                         `
                    -Surname $_.'name.last'                       `
                    -PostalCode $_.'location.postcode'                       `
                    -UserPrincipalName $upn                       `
                    -Mobile $_.'cell'                      `
                    -TelephoneNumber $_.'phone'                       `
                    -UsageLocation $_.nat   `
                    -State $_.'location.state'                   `
                    -StreetAddress ($_.'location.street.name' + " " + $_.'location.street.number')                       `
                    -MailNickName  ($_.email -replace "@example.com","")                     `
                    -PasswordProfile $PasswordProfile `
                    -Verbose        
                                   `
    $pic = Invoke-WebRequest -Uri $user.'picture.large'
    Set-AzureADUserThumbnailPhoto -ObjectId $newUser.objectid -FileStream $pic.RawContentStream -Verbose

    # show pic
    #Get-AzureADUserThumbnailPhoto -ObjectId $newUser.objectid -View $true
    
    # set dates
    #Update-MgUser -UserId $newUser.objectid -Birthday $_.'dob.date' -HireDate $_.'registered.date' -EmployeeHireDate $_.'registered.date'
    $picUrl = '<img src="'+$_.'picture.thumbnail'+'">'
    $report += $newUser | Select-Object Displayname,UserPrincipalName,MailNickName,usagelocation,@{name="Pic";expression={$picUrl}} | ConvertTo-Html -Fragment -As Table | Out-String
}

# send report
Send-ReportbyMail -credentials $cred -To slueders@baggenstos.ch -From admin@M365x682019.onmicrosoft.com -subject ("New User Report " + (get-date -format d)) -body ([System.Web.HttpUtility]::HtmlDecode($report))

# export HTML
[System.Web.HttpUtility]::HtmlDecode($report) | Out-File C:\temp\htmlReport.htm
