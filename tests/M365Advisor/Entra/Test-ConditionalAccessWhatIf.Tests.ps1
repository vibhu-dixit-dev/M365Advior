BeforeDiscovery {
    try {
        $EntraIDPlan = Get-MtLicenseInformation -Product 'EntraID'
        $RegularUsers = Get-MtUser -Count 5 -UserType 'Member'
        $AdminUsers = Get-MtUser -Count 5 -UserType 'Admin'
        $EmergencyAccessUsers = Get-MtUser -Count 5 -UserType 'EmergencyAccess'
        # Remove emergency access users from regular users
        if ($RegularUsers -and $EmergencyAccessUsers) {
            $RegularUsers = $RegularUsers | Where-Object { $_.id -notin $EmergencyAccessUsers.id }
        }
        # Remove emergency access users from admin users
        if ($AdminUsers -and $EmergencyAccessUsers) {
            $AdminUsers = $AdminUsers | Where-Object { $_.id -notin $EmergencyAccessUsers.id }
        }
        Write-Verbose "EntraIDPlan: $EntraIDPlan"
        Write-Verbose "RegularUsers: $($RegularUsers.id)"
        Write-Verbose "AdminUsers: $($AdminUsers.id)"
    } catch {
        $EntraIDPlan = "NotConnected"
    }

    $RegularUsersList = if ($RegularUsers) { @($RegularUsers) } else { @() }
    $EmergencyAccessUsersList = if ($EmergencyAccessUsers) { @($EmergencyAccessUsers) } else { @() }
}


Describe 'M365Advisor/Entra' -Tag 'CA', 'CAWhatIf', 'LongRunning', 'M365Advisor' {

    Context 'M365Advisor/Entra' -ForEach $RegularUsersList {
        # Regular users
        It "MT.1033.$($RegularUsersList.IndexOf($_)): User should be blocked from using legacy authentication ($($_.userPrincipalName))" -Tag 'MT.1033', 'CA', 'CAWhatIf', 'LongRunning', 'M365Advisor' -Skip:( $EntraIDPlan -eq 'Free' ) {
            Test-MtCaWIFBlockLegacyAuthentication -UserId $id | Should -Be $true
        }

    }

    Context 'M365Advisor/Entra' -ForEach $EmergencyAccessUsersList {
        # Emergency access users
        It "MT.1034.$($EmergencyAccessUsersList.IndexOf($_)): Emergency access users should not be blocked ($($_.userPrincipalName))" -Tag 'MT.1034' {
            if ( ( Get-MtLicenseInformation EntraID ) -eq 'Free' ) {
                Add-MtTestResultDetail -SkippedBecause NotLicensedEntraIDP1
            } else {
                Test-MtConditionalAccessWhatIf -UserId $id -IncludeApplications '00000002-0000-0ff1-ce00-000000000000' -ClientAppType exchangeActiveSync | Should -BeNullOrEmpty
            }
        }

    }

}

