##########################################################################
# ISO 27001 / ISO 27002 - Entra ID Security & Governance Tests
# Ported from M365-Assess: Entra/*
# Controls: A.5.15, A.5.16, A.5.18, A.8.2, A.8.3, A.8.5, A.8.9
##########################################################################

Describe "ISO 27001 - Entra ID Admin Accounts" -Tag "ISO 27001", "ISO 27002", "ISO27001:A.5.18", "ISO27002:A.5.18" {
    BeforeAll {
        $script:graphConnected = $false
        try {
            $context = Get-MgContext -ErrorAction Stop
            if ($context -and $context.TenantId) {
                $script:graphConnected = $true
            }
        } catch {}

        $script:gaRoleTemplateId = '62e90394-69f5-4237-9190-012177145e10'
        $script:praRoleTemplateId = 'e8611ab8-c189-46e8-94e1-60213ab1f814'

        $script:subscribedSkus = $null
        try {
            $script:subscribedSkus = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/subscribedSkus' -ErrorAction Stop
        } catch {}

        # Detect Entra ID P2 license for PIM / Access Reviews
        $script:hasP2License = $false
        if ($script:subscribedSkus -and $script:subscribedSkus['value']) {
            $aadP2PlanId = 'eec0eb4f-6444-4f95-aba0-50c24d67f998'
            foreach ($sku in $script:subscribedSkus['value']) {
                if ($sku['capabilityStatus'] -ne 'Enabled') { continue }
                $plans = if ($sku['servicePlans']) { @($sku['servicePlans']) } else { @() }
                foreach ($sp in $plans) {
                    if ($sp['servicePlanId'] -eq $aadP2PlanId -and $sp['provisioningStatus'] -eq 'Success') {
                        $script:hasP2License = $true
                        break
                    }
                }
                if ($script:hasP2License) { break }
            }
        }
    }

    It "ISO27001.A.5.18.1: Operational Global Administrators count must be between 2 and 4" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $gaRole = $null
        try {
            $gaRole = Invoke-MgGraphRequest -Method GET -Uri "/v1.0/directoryRoles?`$filter=displayName eq 'Global Administrator'" -ErrorAction Stop
        } catch {
            throw "Failed to fetch directory roles: $($_.Exception.Message)"
        }

        if (-not $gaRole -or -not $gaRole['value'] -or $gaRole['value'].Count -eq 0) {
            Set-ItResult -Skipped -Because "Global Administrator directory role is not activated in this tenant"
            return
        }

        $roleId = $gaRole['value'][0]['id']
        $membersResp = Invoke-MgGraphRequest -Method GET -Uri "/v1.0/directoryRoles/$roleId/members" -ErrorAction Stop
        $allAdmins = if ($membersResp -and $membersResp['value']) { @($membersResp['value']) } else { @() }

        # Simple heuristic to identify break-glass/emergency accounts from UPN/DisplayName
        $operationalAdmins = @($allAdmins | Where-Object {
            $upn = ("$($_['userPrincipalName'])".ToLower())
            $name = ("$($_['displayName'])".ToLower())
            -not ($upn -match 'breakglass|emergency|bypass|emergencyadmin' -or $name -match 'break-glass|emergency')
        })

        $gaCount = $operationalAdmins.Count
        $gaCount | Should -BeGreaterOrEqual 2 -Because "ISO A.5.18 requires redundancy - at least 2 Global Administrators are needed for emergency access"
        $gaCount | Should -BeLessOrEqual 4 -Because "ISO A.5.18 requires minimizing privileged roles - no more than 4 Global Administrators should exist"
    }

    It "ISO27001.A.5.18.2: PIM must manage Global Administrator role (no permanent standing assignments)" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:hasP2License) {
            Set-ItResult -Skipped -Because "PIM requires an Entra ID P2 license which is not present"
            return
        }

        $gaRoleResp = $null
        try {
            $gaRoleResp = Invoke-MgGraphRequest -Method GET -Uri "/v1.0/directoryRoles(roleTemplateId='$script:gaRoleTemplateId')/members" -ErrorAction Stop
        } catch {
            throw "Failed to fetch GA role members: $($_.Exception.Message)"
        }

        $gaMembers = if ($gaRoleResp -and $gaRoleResp['value']) { @($gaRoleResp['value']) } else { @() }

        $eligibleResp = Invoke-MgGraphRequest -Method GET -Uri "/beta/roleManagement/directory/roleEligibilityScheduleInstances?`$filter=roleDefinitionId eq '$script:gaRoleTemplateId'" -ErrorAction SilentlyContinue
        $eligibleIds = if ($eligibleResp -and $eligibleResp['value']) {
            @($eligibleResp['value'] | ForEach-Object { $_['principalId'] })
        } else { @() }

        $permanentGAs = @($gaMembers | Where-Object { $_['id'] -notin $eligibleIds })
        $permanentGAs.Count | Should -Be 0 -Because "ISO A.5.18 requires privileged roles to use JIT access (PIM) - no standing permanent GA assignments are allowed"
    }

    It "ISO27001.A.5.18.3: Guest access reviews must be configured" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:hasP2License) {
            Set-ItResult -Skipped -Because "Access reviews require an Entra ID P2 license"
            return
        }

        $reviews = $null
        try {
            $reviews = Invoke-MgGraphRequest -Method GET -Uri '/beta/identityGovernance/accessReviews/definitions?$top=100' -ErrorAction Stop
        } catch {
            Set-ItResult -Skipped -Because "Unable to query access review definitions: $($_.Exception.Message)"
            return
        }

        $allReviews = if ($reviews -and $reviews['value']) { @($reviews['value']) } else { @() }
        $guestReviews = @($allReviews | Where-Object {
            $_['scope'] -and ($_['scope']['query'] -match 'guest' -or $_['scope']['@odata.type'] -match 'guest')
        })

        $guestReviews.Count | Should -BeGreaterOrEqual 1 -Because "ISO A.5.18 / A.5.16 require periodic reviews of guest access to maintain authorization controls"
    }

    It "ISO27001.A.5.18.4: Privileged roles access reviews must be configured" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:hasP2License) {
            Set-ItResult -Skipped -Because "Access reviews require an Entra ID P2 license"
            return
        }

        $reviews = $null
        try {
            $reviews = Invoke-MgGraphRequest -Method GET -Uri '/beta/identityGovernance/accessReviews/definitions?$top=100' -ErrorAction Stop
        } catch {
            Set-ItResult -Skipped -Because "Unable to query access review definitions"
            return
        }

        $allReviews = if ($reviews -and $reviews['value']) { @($reviews['value']) } else { @() }
        $roleReviews = @($allReviews | Where-Object {
            $_['scope'] -and ($_['scope']['query'] -match 'roleManagement|directoryRole')
        })

        $roleReviews.Count | Should -BeGreaterOrEqual 1 -Because "ISO A.5.18 requires periodic reviews of administrator assignments to enforce least privilege"
    }

    It "ISO27001.A.5.18.5: Global Administrator activation must require approval" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:hasP2License) {
            Set-ItResult -Skipped -Because "PIM activation policy requires an Entra ID P2 license"
            return
        }

        $filter = "scopeId eq '/' and scopeType eq 'DirectoryRole' and roleDefinitionId eq '$script:gaRoleTemplateId'"
        $uri = "/v1.0/policies/roleManagementPolicyAssignments?`$filter=$filter&`$expand=policy(`$expand=rules)"
        $assignmentsResp = $null
        try {
            $assignmentsResp = Invoke-MgGraphRequest -Method GET -Uri $uri -ErrorAction Stop
        } catch {
            Set-ItResult -Skipped -Because "Unable to read PIM activation policy for Global Administrator"
            return
        }

        $assignment = if ($assignmentsResp -and $assignmentsResp['value']) { @($assignmentsResp['value'])[0] } else { $null }
        $rules = if ($assignment -and $assignment['policy'] -and $assignment['policy']['rules']) {
            @($assignment['policy']['rules'])
        } else { @() }

        $approvalRule = $rules | Where-Object { $_['@odata.type'] -match 'ApprovalRule' } | Select-Object -First 1
        $approvalRequired = $false
        if ($approvalRule -and $approvalRule['setting']) {
            $approvalRequired = [bool]$approvalRule['setting']['isApprovalRequired']
        }

        $approvalRequired | Should -Be $true -Because "ISO A.5.18 requires high-impact role activation to be authorized by a secondary reviewer"
    }

    It "ISO27001.A.5.18.6: Privileged Role Administrator activation must require approval" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:hasP2License) {
            Set-ItResult -Skipped -Because "PIM activation policy requires an Entra ID P2 license"
            return
        }

        $filter = "scopeId eq '/' and scopeType eq 'DirectoryRole' and roleDefinitionId eq '$script:praRoleTemplateId'"
        $uri = "/v1.0/policies/roleManagementPolicyAssignments?`$filter=$filter&`$expand=policy(`$expand=rules)"
        $assignmentsResp = $null
        try {
            $assignmentsResp = Invoke-MgGraphRequest -Method GET -Uri $uri -ErrorAction Stop
        } catch {
            Set-ItResult -Skipped -Because "Unable to read PIM activation policy for Privileged Role Administrator"
            return
        }

        $assignment = if ($assignmentsResp -and $assignmentsResp['value']) { @($assignmentsResp['value'])[0] } else { $null }
        $rules = if ($assignment -and $assignment['policy'] -and $assignment['policy']['rules']) {
            @($assignment['policy']['rules'])
        } else { @() }

        $approvalRule = $rules | Where-Object { $_['@odata.type'] -match 'ApprovalRule' } | Select-Object -First 1
        $approvalRequired = $false
        if ($approvalRule -and $approvalRule['setting']) {
            $approvalRequired = [bool]$approvalRule['setting']['isApprovalRequired']
        }

        $approvalRequired | Should -Be $true -Because "ISO A.5.18 requires Privileged Role Administrator activation to be authorized by a secondary reviewer"
    }

    It "ISO27001.A.5.18.7: All Global Administrator accounts must be cloud-only" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $gaMembers = $null
        try {
            $gaMembers = Invoke-MgGraphRequest -Method GET -Uri "/v1.0/directoryRoles/roleTemplateId=$script:gaRoleTemplateId/members?`$select=displayName,userPrincipalName,onPremisesSyncEnabled" -ErrorAction Stop
        } catch {
            throw "Failed to fetch GA role members"
        }

        $gaList = if ($gaMembers -and $gaMembers['value']) { @($gaMembers['value']) } else { @() }
        $syncedAdmins = @($gaList | Where-Object { $_['onPremisesSyncEnabled'] -eq $true })

        $syncedAdmins.Count | Should -Be 0 -Because "ISO A.5.18 requires admin accounts to be decoupled from on-premises directories to prevent domain controller compromise escalation"
    }

    It "ISO27001.A.5.18.8: Global Administrators must not be assigned full M365 E3/E5 productivity licenses" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $gaUsersLicense = $null
        try {
            $gaUsersLicense = Invoke-MgGraphRequest -Method GET -Uri "/v1.0/directoryRoles/roleTemplateId=$script:gaRoleTemplateId/members?`$select=displayName,assignedLicenses" -ErrorAction Stop
        } catch {
            throw "Failed to fetch GA license assignments"
        }

        # Common productivity SKU IDs (M365/O365 E3 and E5 suites)
        $productivitySkus = @(
            '05e9a617-0261-4cee-bb36-b42c3d50e6a0', # SPE_E3 (M365 E3)
            '06ebc4ee-1bb5-47dd-8120-11324bc54e06', # SPE_E5 (M365 E5)
            '6fd2c87f-b296-42f0-b197-1e91e994b900', # ENTERPRISEPACK (O365 E3)
            'c7df2760-2c81-4ef7-b578-5b5392b571df'  # ENTERPRISEPREMIUM (O365 E5)
        )

        $gaLicenseList = if ($gaUsersLicense -and $gaUsersLicense['value']) { @($gaUsersLicense['value']) } else { @() }
        $heavyLicensed = @($gaLicenseList | Where-Object {
            $licenses = $_['assignedLicenses']
            $licenses | Where-Object { $productivitySkus -contains $_['skuId'] }
        })

        $heavyLicensed.Count | Should -Be 0 -Because "ISO A.5.18 / A.8.9 require dedicated admin accounts with minimal scope - admin accounts should not have mailboxes/OneDrive to mitigate phishing risk"
    }

    It "ISO27001.A.8.3.1: Restrict non-admin users from accessing Microsoft Entra admin center" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $authPolicy = $null
        try {
            $authPolicy = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/policies/authorizationPolicy' -ErrorAction Stop
        } catch {
            throw "Failed to fetch authorization policy: $($_.Exception.Message)"
        }

        $restricted = $authPolicy['restrictNonAdminUsers']
        $restricted | Should -Be $true -Because "ISO A.8.3 / A.5.15 require limiting access to management directories to administrative accounts only"
    }

    It "ISO27001.A.8.5.1: All Global Administrators must have MFA registered" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $adminMembers = Invoke-MgGraphRequest -Method GET -Uri "/v1.0/directoryRoles/roleTemplateId=$script:gaRoleTemplateId/members?`$select=id,displayName" -ErrorAction Stop
        $adminList = if ($adminMembers -and $adminMembers['value']) { @($adminMembers['value']) } else { @() }

        if ($adminList.Count -eq 0) {
            Set-ItResult -Skipped -Because "No Global Administrator members found to verify MFA"
            return
        }

        $mfaDetails = Invoke-MgGraphRequest -Method GET -Uri '/beta/reports/authenticationMethods/userRegistrationDetails' -ErrorAction Stop
        $mfaList = if ($mfaDetails -and $mfaDetails['value']) { @($mfaDetails['value']) } else { @() }

        $adminIds = @($adminList | ForEach-Object { $_['id'] })
        $adminMfa = @($mfaList | Where-Object { $_['id'] -in $adminIds })

        $adminsNoMfa = @($adminMfa | Where-Object { -not $_['isMfaRegistered'] })
        $adminsNoMfa.Count | Should -Be 0 -Because "ISO A.8.5 / A.5.15 require strong authentication controls for all administrative roles"
    }
}

Describe "ISO 27001 - Entra ID Password & MFA Settings" -Tag "ISO 27001", "ISO 27002", "ISO27001:A.8.5", "ISO27001:A.5.15", "ISO27002:A.8.5", "ISO27002:A.5.15" {
    BeforeAll {
        $script:authMethodsPolicy = $null
        try {
            $script:authMethodsPolicy = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/policies/authenticationMethodsPolicy' -ErrorAction Stop
        } catch {}
    }

    It "ISO27001.A.5.15.1: Security Defaults or equivalent Conditional Access policies must be enabled" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $secDefaults = $null
        try {
            $secDefaults = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/policies/identitySecurityDefaultsEnforcementPolicy' -ErrorAction Stop
        } catch {
            throw "Failed to fetch security defaults policy"
        }

        $sdEnabled = $secDefaults['isEnabled']
        if ($sdEnabled -eq $true) {
            $sdEnabled | Should -Be $true -Because "Security defaults are enabled"
            return
        }

        # If security defaults is off, evaluate if there are active Conditional Access policies
        $caResp = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/identity/conditionalAccess/policies' -ErrorAction Stop
        $policies = if ($caResp -and $caResp['value']) { @($caResp['value']) } else { @() }
        $enabledCount = @($policies | Where-Object { $_['state'] -eq 'enabled' }).Count

        $enabledCount | Should -BeGreaterThan 0 -Because "ISO A.5.15 / A.8.5 require tenant security defaults or active Conditional Access policies for MFA enforcement"
    }

    It "ISO27001.A.8.5.2: Telephony-based authentication methods (SMS and Voice) must be disabled" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:authMethodsPolicy) {
            Set-ItResult -Skipped -Because "Authentication methods policy not available"
            return
        }

        $authMethods = $script:authMethodsPolicy['authenticationMethodConfigurations']
        if (-not $authMethods) {
            Set-ItResult -Skipped -Because "No auth method configurations returned"
            return
        }

        $smsMethod = $authMethods | Where-Object { $_['id'] -eq 'Sms' }
        $smsState = if ($smsMethod) { $smsMethod['state'] } else { 'disabled' }
        $smsState | Should -Be 'disabled' -Because "ISO A.8.5 requires disabling weak factors - SMS authentication is vulnerable to SIM swap attacks"

        $voiceMethod = $authMethods | Where-Object { $_['id'] -eq 'Voice' }
        $voiceState = if ($voiceMethod) { $voiceMethod['state'] } else { 'disabled' }
        $voiceState | Should -Be 'disabled' -Because "ISO A.8.5 requires disabling weak factors - Voice call authentication is vulnerable to telephony-based intercepts"
    }

    It "ISO27001.A.8.5.3: Email OTP authentication must be disabled" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:authMethodsPolicy) {
            Set-ItResult -Skipped -Because "Authentication methods policy not available"
            return
        }

        $authMethods = $script:authMethodsPolicy['authenticationMethodConfigurations']
        $emailMethod = $authMethods | Where-Object { $_['id'] -eq 'Email' }
        $emailState = if ($emailMethod) { $emailMethod['state'] } else { 'disabled' }

        $emailState | Should -Be 'disabled' -Because "ISO A.8.5 requires restricting weak methods - Email OTP is a weak authentication factor"
    }

    It "ISO27001.A.8.5.4: Custom banned password lists must be enabled" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $pwSettings = $null
        try {
            $pwSettingsResp = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/settings' -ErrorAction Stop
            $pwSettings = $pwSettingsResp['value'] | Where-Object { $_['displayName'] -eq 'Password Rule Settings' }
        } catch {
            # 404 or BadRequest is common when never configured (uses Microsoft default, custom list not active)
        }

        if (-not $pwSettings) {
            $null | Should -Not -Be $null -Because "ISO A.8.5 requires enforcing banned passwords - Custom banned password list has not been initialized"
            return
        }

        $enforceCustomEntry = $pwSettings['values'] | Where-Object { $_['name'] -eq 'EnableBannedPasswordCheck' }
        $enforceCustom = if ($enforceCustomEntry) { $enforceCustomEntry['value'] } else { 'False' }

        $enforceCustom | Should -Be 'True' -Because "ISO A.8.5 requires custom banned password check to be explicitly enabled"
    }

    It "ISO27001.A.8.5.5: Smart Lockout threshold must be 10 or fewer attempts" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $pwSettings = $null
        try {
            $pwSettingsResp = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/settings' -ErrorAction Stop
            $pwSettings = $pwSettingsResp['value'] | Where-Object { $_['displayName'] -eq 'Password Rule Settings' }
        } catch {}

        if (-not $pwSettings) {
            Set-ItResult -Skipped -Because "Directory settings not customized (using default smart lockout)"
            return
        }

        $lockoutEntry = $pwSettings['values'] | Where-Object { $_['name'] -eq 'LockoutThreshold' }
        $lockoutThreshold = if ($lockoutEntry) { [int]$lockoutEntry['value'] } else { 10 }

        $lockoutThreshold | Should -BeLessOrEqual 10 -Because "ISO A.8.5 requires smart lockout thresholds to restrict brute-force password guessing attempts"
    }

    It "ISO27001.A.8.5.6: Verified domains must have passwords set to never expire (with MFA)" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $domains = $null
        try {
            $domains = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/domains' -ErrorAction Stop
        } catch {
            throw "Failed to fetch domains"
        }

        $domainList = if ($domains -and $domains['value']) { @($domains['value']) } else { @() }
        $verifiedDomains = @($domainList | Where-Object { $_['isVerified'] -eq $true })

        if ($verifiedDomains.Count -eq 0) {
            Set-ItResult -Skipped -Because "No verified domains found"
            return
        }

        $failingDomains = @()
        foreach ($dom in $verifiedDomains) {
            $validityDays = $dom['passwordValidityPeriodInDays']
            if ($validityDays -ne 2147483647) { $failingDomains += $dom['id'] }
        }

        $failingDomains.Count | Should -Be 0 -Because "ISO A.8.5 recommends password-never-expires policy (when MFA is enforced) to prevent predictable password updates"
    }

    It "ISO27001.A.8.5.7: Authenticator fatigue protection (number matching + app info context) must be enabled" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:authMethodsPolicy) {
            Set-ItResult -Skipped -Because "Authentication methods policy not available"
            return
        }

        $authMethods = $script:authMethodsPolicy['authenticationMethodConfigurations']
        $authenticator = $authMethods | Where-Object { $_['id'] -eq 'MicrosoftAuthenticator' }

        if (-not $authenticator) {
            Set-ItResult -Skipped -Because "Microsoft Authenticator not configured"
            return
        }

        $featureSettings = $authenticator['featureSettings']
        if (-not $featureSettings) {
            throw "Feature settings for Authenticator are missing"
        }

        $numberMatchState = $featureSettings['numberMatchingRequiredState']
        $appInfoState = $featureSettings['displayAppInformationRequiredState']

        # Absent or default means enabled/enforced by MS default
        $numberMatch = if ($numberMatchState) { $numberMatchState['state'] } else { 'default' }
        $appInfo = if ($appInfoState) { $appInfoState['state'] } else { 'disabled' }

        $numberMatchOn = $numberMatch -in @('enabled', 'default')
        $appInfoOn = $appInfo -eq 'enabled'

        $numberMatchOn | Should -Be $true -Because "ISO A.8.5 requires Authenticator number matching to prevent accidental MFA approvals"
        $appInfoOn | Should -Be $true -Because "ISO A.8.5 requires application context display in MFA prompts to block MFA fatigue attacks"
    }

    It "ISO27001.A.8.5.8: System-Preferred MFA must be enabled" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:authMethodsPolicy) {
            Set-ItResult -Skipped -Because "Authentication methods policy not available"
            return
        }

        $systemPreferred = $script:authMethodsPolicy['systemCredentialPreferences']
        # Absent or default resolves to enabled by Microsoft
        $sysState = if ($systemPreferred) { $systemPreferred['state'] } else { 'enabled' }
        $sysEnabled = $sysState -in @('enabled', 'default')

        $sysEnabled | Should -Be $true -Because "ISO A.8.5 requires system-preferred MFA to prompt users for their strongest registered method first"
    }
}

Describe "ISO 27001 - Entra ID Device Settings" -Tag "ISO 27001", "ISO 27002", "ISO27001:A.8.2", "ISO27001:A.8.9", "ISO27002:A.8.2", "ISO27002:A.8.9" {
    BeforeAll {
        $script:devicePolicy = $null
        try {
            $script:devicePolicy = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/policies/deviceRegistrationPolicy' -ErrorAction Stop
        } catch {}

        $script:devicePolicyBeta = $null
        try {
            $script:devicePolicyBeta = Invoke-MgGraphRequest -Method GET -Uri '/beta/policies/deviceRegistrationPolicy' -ErrorAction Stop
        } catch {}
    }

    It "ISO27001.A.8.2.1: Microsoft Entra Join permissions must be restricted (not set to All)" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:devicePolicy) {
            Set-ItResult -Skipped -Because "Device registration policy not accessible"
            return
        }

        $joinType = $script:devicePolicy['azureADJoin']['allowedToJoin']['@odata.type']
        $joinRestricted = $joinType -ne '#microsoft.graph.allDeviceRegistrationMembership'

        $joinRestricted | Should -Be $true -Because "ISO A.8.2 / A.8.9 require limiting device registration permission to authorized user groups to prevent unmanaged device join"
    }

    It "ISO27001.A.8.9.1: Maximum device quota per user must be 15 or fewer" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:devicePolicy) {
            Set-ItResult -Skipped -Because "Device registration policy not accessible"
            return
        }

        $maxDevices = $script:devicePolicy['userDeviceQuota']
        $maxDevices | Should -BeLessOrEqual 15 -Because "ISO A.8.9 requires restricting the maximum number of devices a user can join to reduce attack surface"
    }

    It "ISO27001.A.8.3.2: Global Administrator role must not be added as local administrator on Entra-joined devices" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:devicePolicy) {
            Set-ItResult -Skipped -Because "Device registration policy not accessible"
            return
        }

        $gaLocalAdmin = $true
        if ($script:devicePolicy['azureADJoin']['localAdmins']) {
            $gaLocalAdmin = $script:devicePolicy['azureADJoin']['localAdmins']['enableGlobalAdmins']
        }

        $gaLocalAdmin | Should -Be $false -Because "ISO A.8.3 requires restriction of administrative access - adding GAs as local admins exposes their accounts to compromise on user endpoints"
    }

    It "ISO27001.A.8.9.2: Local Administrator Password Solution (LAPS) must be enabled in Entra ID" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:devicePolicyBeta) {
            Set-ItResult -Skipped -Because "Beta device registration policy not accessible"
            return
        }

        $lapsEnabled = $false
        if ($script:devicePolicyBeta['localAdminPassword']) {
            $lapsEnabled = $script:devicePolicyBeta['localAdminPassword']['isEnabled']
        }

        $lapsEnabled | Should -Be $true -Because "ISO A.8.9 requires automated local administrator password rotation via cloud LAPS to protect endpoints"
    }
}

Describe "ISO 27001 - Entra ID App Consent & Group Settings" -Tag "ISO 27001", "ISO 27002", "ISO27001:A.8.9", "ISO27001:A.8.3", "ISO27002:A.8.9", "ISO27002:A.8.3" {
    BeforeAll {
        $script:authPolicy = $null
        try {
            $script:authPolicy = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/policies/authorizationPolicy' -ErrorAction Stop
        } catch {}
    }

    It "ISO27001.A.8.9.3: User consent for applications must be blocked" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:authPolicy) {
            Set-ItResult -Skipped -Because "Authorization policy not available"
            return
        }

        $consentPolicy = $script:authPolicy['defaultUserRolePermissions']['permissionGrantPoliciesAssigned']
        $isRestricted = ($null -eq $consentPolicy) -or ($consentPolicy.Count -eq 0)

        $isRestricted | Should -Be $true -Because "ISO A.8.9 / A.8.3 require blocking end-user application consent to prevent unauthorized data access by third-party integrations"
    }

    It "ISO27001.A.8.9.4: Users must not be allowed to register custom applications" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:authPolicy) {
            Set-ItResult -Skipped -Because "Authorization policy not available"
            return
        }

        $canRegister = $script:authPolicy['defaultUserRolePermissions']['allowedToCreateApps']
        $canRegister | Should -Be $false -Because "ISO A.8.9 requires restricting developer features in production - end users should not register OAuth applications"
    }

    It "ISO27001.A.5.16.1: Users must not be allowed to create security groups" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:authPolicy) {
            Set-ItResult -Skipped -Because "Authorization policy not available"
            return
        }

        $canCreateGroups = $script:authPolicy['defaultUserRolePermissions']['allowedToCreateSecurityGroups']
        $canCreateGroups | Should -Be $false -Because "ISO A.5.16 / A.8.9 require structured group governance to maintain accurate access boundaries"
    }

    It "ISO27001.A.8.9.5: Non-admin users must be restricted from creating directories/tenants" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        if (-not $script:authPolicy) {
            Set-ItResult -Skipped -Because "Authorization policy not available"
            return
        }

        $canCreateTenants = $script:authPolicy['defaultUserRolePermissions']['allowedToCreateTenants']
        $canCreateTenants | Should -Be $false -Because "ISO A.8.9 requires restricting unauthorized shadow IT tenant creation under the corporate root"
    }

    It "ISO27001.A.8.9.6: Admin Consent Workflow must be enabled" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $adminConsentSettings = $null
        try {
            $adminConsentSettings = Invoke-MgGraphRequest -Method GET -Uri '/v1.0/policies/adminConsentRequestPolicy' -ErrorAction Stop
        } catch {
            throw "Failed to fetch admin consent request policy"
        }

        $adminConsentSettings['isEnabled'] | Should -Be $true -Because "ISO A.8.9 requires a structured admin consent workflow to allow request, review, and approval of enterprise integrations"
    }

    It "ISO27001.A.8.9.7: LinkedIn account connections must be disabled" {
        if (-not $script:graphConnected) {
            Set-ItResult -Skipped -Because "Not authenticated to Microsoft Graph"
            return
        }

        $tenantId = $null
        try {
            $context = Get-MgContext
            $tenantId = $context.TenantId
        } catch {}

        if (-not $tenantId) {
            Set-ItResult -Skipped -Because "Tenant ID could not be determined"
            return
        }

        $orgSettings = $null
        try {
            $orgSettings = Invoke-MgGraphRequest -Method GET -Uri "/beta/organization/$tenantId" -ErrorAction Stop
        } catch {
            throw "Failed to fetch organization settings"
        }

        $linkedInEnabled = $true
        if ($orgSettings -and $orgSettings['linkedInConfiguration']) {
            $linkedInEnabled = -not $orgSettings['linkedInConfiguration']['isDisabled']
        }

        $linkedInEnabled | Should -Be $false -Because "ISO A.8.9 requires disabling consumer directory synchronization to prevent data leakage of user information"
    }
}
