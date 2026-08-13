##########################################################################
# ISO 27001 / ISO 27002 - Teams Security Tests
# Ported from M365-Assess: Collaboration/Get-TeamsSecurityConfig.ps1
# Controls: A.5.14, A.5.23, A.8.4, A.8.20
##########################################################################

Describe "ISO 27001 - Teams External Access" -Tag "ISO 27001", "ISO 27002", "ISO27001:A.5.23", "ISO27001:A.5.14", "ISO27002:A.5.23", "ISO27002:A.5.14" {
    BeforeAll {
        try {
            $script:teamsClientConfig = Invoke-MgGraphRequest -Method GET -Uri '/beta/teamwork/teamsClientConfiguration' -ErrorAction Stop
        } catch {
            $script:teamsClientConfig = $null
        }
    }

    It "ISO27001.A.5.23.1: Communication with unmanaged Teams users (personal accounts) must be disabled" {
        if (-not $script:teamsClientConfig) {
            Set-ItResult -Skipped -Because "Teams client config endpoint not available in this cloud environment (GCC High/DoD)"
            return
        }
        $script:teamsClientConfig['allowTeamsConsumer'] | Should -Be $false `
            -Because "ISO A.5.23 requires restricting external access - personal Teams accounts are unmanaged and pose data leakage risk"
    }

    It "ISO27001.A.5.23.2: External unmanaged Teams users must not be able to initiate conversations" {
        if (-not $script:teamsClientConfig) {
            Set-ItResult -Skipped -Because "Teams client config endpoint not available in this cloud environment"
            return
        }
        $script:teamsClientConfig['allowTeamsConsumerInbound'] | Should -Be $false `
            -Because "ISO A.5.23 requires inbound communications from unmanaged external accounts to be blocked"
    }

    It "ISO27001.A.5.14.8: External Teams domain access must be disabled or restricted to specific domains" {
        if (-not $script:teamsClientConfig) {
            Set-ItResult -Skipped -Because "Teams client config endpoint not available in this cloud environment"
            return
        }
        $allowFederated = $script:teamsClientConfig['allowFederatedUsers']
        $allowedDomains = $script:teamsClientConfig['allowedDomains']
        $isRestricted = (-not $allowFederated) -or ($allowedDomains -and $allowedDomains.Count -gt 0)
        $isRestricted | Should -Be $true `
            -Because "ISO A.5.14 requires external collaboration to be limited to trusted domains only"
    }

    It "ISO27001.A.5.23.3: Skype for Business / consumer interop must be disabled" {
        if (-not $script:teamsClientConfig) {
            Set-ItResult -Skipped -Because "Teams client config endpoint not available in this cloud environment"
            return
        }
        $script:teamsClientConfig['allowPublicUsers'] | Should -Be $false `
            -Because "ISO A.5.23 requires disabling Skype consumer federation - unmanaged external users pose security risks"
    }
}

Describe "ISO 27001 - Teams Client Configuration" -Tag "ISO 27001", "ISO 27002", "ISO27001:A.8.20", "ISO27001:A.5.14", "ISO27002:A.8.20", "ISO27002:A.5.14" {
    BeforeAll {
        try {
            $script:teamsClientConfig2 = Invoke-MgGraphRequest -Method GET -Uri '/beta/teamwork/teamsClientConfiguration' -ErrorAction Stop
        } catch {
            $script:teamsClientConfig2 = $null
        }
    }

    It "ISO27001.A.8.20.4: Third-party cloud storage providers must be disabled in Teams" {
        if (-not $script:teamsClientConfig2) {
            Set-ItResult -Skipped -Because "Teams client config endpoint not available in this cloud environment"
            return
        }
        $enabledStores = @()
        $cloudStorageKeys = @('allowDropBox', 'allowBox', 'allowGoogleDrive', 'allowShareFile', 'allowEgnyte')
        foreach ($key in $cloudStorageKeys) {
            if ($script:teamsClientConfig2.ContainsKey($key) -and $script:teamsClientConfig2[$key]) {
                $enabledStores += $key
            }
        }
        $enabledStores.Count | Should -Be 0 `
            -Because "ISO A.8.20 requires data to remain in approved storage locations - third-party cloud storage bypasses corporate data governance"
    }

    It "ISO27001.A.8.20.5: Email-into-Channel must be disabled" {
        if (-not $script:teamsClientConfig2) {
            Set-ItResult -Skipped -Because "Teams client config endpoint not available in this cloud environment"
            return
        }
        $script:teamsClientConfig2['allowEmailIntoChannel'] | Should -Be $false `
            -Because "ISO A.8.20 requires controlling information flow - emailing into channels can bypass DLP policies"
    }
}

Describe "ISO 27001 - Teams Meeting Policies" -Tag "ISO 27001", "ISO 27002", "ISO27001:A.5.14", "ISO27001:A.8.4", "ISO27002:A.5.14", "ISO27002:A.8.4" {
    BeforeAll {
        try {
            $script:meetingPolicy = Invoke-MgGraphRequest -Method GET -Uri '/beta/teamwork/teamsMeetingPolicy' -ErrorAction Stop
        } catch {
            $script:meetingPolicy = $null
        }
    }

    It "ISO27001.A.5.14.9: Anonymous users must not be able to join meetings" {
        if (-not $script:meetingPolicy) {
            Set-ItResult -Skipped -Because "Teams meeting policy endpoint not available in this cloud environment"
            return
        }
        $script:meetingPolicy['allowAnonymousUsersToJoinMeeting'] | Should -Be $false `
            -Because "ISO A.5.14 requires restricting meeting access to authenticated identities only"
    }

    It "ISO27001.A.5.14.10: Anonymous users must not be able to start meetings" {
        if (-not $script:meetingPolicy) {
            Set-ItResult -Skipped -Because "Teams meeting policy endpoint not available in this cloud environment"
            return
        }
        $script:meetingPolicy['allowAnonymousUsersToStartMeeting'] | Should -Be $false `
            -Because "ISO A.5.14 requires that only authenticated and authorized users can initiate meetings"
    }

    It "ISO27001.A.8.4.3: Lobby bypass must be restricted to org members only (not everyone)" {
        if (-not $script:meetingPolicy) {
            Set-ItResult -Skipped -Because "Teams meeting policy endpoint not available in this cloud environment"
            return
        }
        $autoAdmit = $script:meetingPolicy['autoAdmittedUsers']
        $isRestricted = $autoAdmit -eq 'EveryoneInCompanyExcludingGuests' -or
                        $autoAdmit -eq 'EveryoneInSameAndFederatedCompany' -or
                        $autoAdmit -eq 'OrganizerOnly' -or $autoAdmit -eq 'InvitedUsers'
        $isRestricted | Should -Be $true `
            -Because "ISO A.8.4 requires access controls on meetings - lobby bypass should not allow 'Everyone' to bypass"
    }

    It "ISO27001.A.8.4.4: Dial-in users must not bypass the meeting lobby" {
        if (-not $script:meetingPolicy) {
            Set-ItResult -Skipped -Because "Teams meeting policy endpoint not available in this cloud environment"
            return
        }
        $script:meetingPolicy['allowPSTNUsersToBypassLobby'] | Should -Be $false `
            -Because "ISO A.8.4 requires unauthenticated PSTN callers to wait in lobby for organizer admission"
    }

    It "ISO27001.A.8.4.5: External participants must not be able to give or request control" {
        if (-not $script:meetingPolicy) {
            Set-ItResult -Skipped -Because "Teams meeting policy endpoint not available in this cloud environment"
            return
        }
        $script:meetingPolicy['allowExternalParticipantGiveRequestControl'] | Should -Be $false `
            -Because "ISO A.8.4 requires restricting external participants from controlling meeting resources and screen sharing"
    }

    It "ISO27001.A.5.14.11: Anonymous users must not be able to use meeting chat" {
        if (-not $script:meetingPolicy) {
            Set-ItResult -Skipped -Because "Teams meeting policy endpoint not available in this cloud environment"
            return
        }
        $meetingChat = $script:meetingPolicy['meetingChatEnabledType']
        $chatRestricted = $meetingChat -ne 'Enabled'
        $chatRestricted | Should -Be $true `
            -Because "ISO A.5.14 requires meeting chat to exclude anonymous users (set to EnabledExceptAnonymous or Disabled)"
    }

    It "ISO27001.A.8.4.6: Default meeting presenter role must be OrganizerOnly" {
        if (-not $script:meetingPolicy) {
            Set-ItResult -Skipped -Because "Teams meeting policy endpoint not available in this cloud environment"
            return
        }
        $script:meetingPolicy['designatedPresenterRoleMode'] | Should -Be 'OrganizerOnlyUserOverride' `
            -Because "ISO A.8.4 requires limiting who can present in meetings - all users should not be able to present by default"
    }

    It "ISO27001.A.5.14.12: External non-trusted users must not be able to use meeting chat" {
        if (-not $script:meetingPolicy) {
            Set-ItResult -Skipped -Because "Teams meeting policy endpoint not available in this cloud environment"
            return
        }
        $script:meetingPolicy['allowExternalNonTrustedMeetingChat'] | Should -Be $false `
            -Because "ISO A.5.14 requires restricting information flow to/from untrusted external participants"
    }

    It "ISO27001.A.5.14.13: Cloud recording must be disabled by default" {
        if (-not $script:meetingPolicy) {
            Set-ItResult -Skipped -Because "Teams meeting policy endpoint not available in this cloud environment"
            return
        }
        $script:meetingPolicy['allowCloudRecording'] | Should -Be $false `
            -Because "ISO A.5.14 requires data minimization - unrestricted cloud recording stores sensitive meeting content"
    }
}
