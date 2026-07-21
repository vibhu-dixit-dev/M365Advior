Describe 'Get-MtM365AdvisorConfig' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../M365Advisor.psd1 -Force
        $m365advisorTestsPath = Join-Path $PSScriptRoot '../../../tests'

        # Copy default config to test location to ensure it exists for the tests
        $testFolder = Join-Path 'TestDrive:' 'm365advisor-config-tests'
        $null = New-Item -Path $testFolder -ItemType Directory
        Copy-Item -Path (Join-Path -Path $m365advisorTestsPath -ChildPath 'm365advisor-config.json') -Destination (Join-Path -Path $testFolder -ChildPath 'm365advisor-config.json')

    }

    It 'Finds and reads a default config' {
        $result = InModuleScope -ModuleName 'M365Advisor' -Parameters @{ testFolder = $testFolder } {
            Get-MtM365AdvisorConfig -Path $testFolder
        }

        $result | Should -Not -BeNullOrEmpty

        $result.GlobalSettings | Should -Not -BeNullOrEmpty
        $result.GlobalSettings.EmergencyAccessAccounts | Should -BeNullOrEmpty

        $result.TestSettings.Count | Should -BeGreaterThan 0
        $sample = $result.TestSettings | Where-Object Id -eq 'MT.1001'
        $sample.Severity | Should -Not -Be 'Info'
        #$sample.Title | Should -Not -Be 'Overridden Title from Custom Config'

        $result.ConfigSource | Should -Be 'm365advisor-config.json'

        # Version fields survive load
        $result.PSObject.Properties.Name | Should -Contain 'ModuleVersion'
        $result.ModuleVersion | Should -Not -BeNullOrEmpty
        $result.PSObject.Properties.Name | Should -Contain 'ConfigVersion'
    }

    Context 'Tenant-specific config' {
        BeforeAll {
            $tenantId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
            $tenantConfigPath = Join-Path $testFolder "m365advisor-config.$tenantId.json"
            Set-Content -Path $tenantConfigPath -Value (@{
                GlobalSettings = @{
                    EmergencyAccessAccounts = @(
                        @{
                            Type = 'User'
                            UserPrincipalName = 'BreakGlass@tenant-specific.com'
                        }
                    )
                }
                TestSettings = @(
                    @{
                        Id = 'MT.1001'
                        Severity = 'Critical'
                        Title = 'Tenant-specific title'
                    }
                )
            } | ConvertTo-Json -Depth 5)
        }

        It 'Loads tenant-specific config when TenantId matches a file' {
            $result = InModuleScope -ModuleName 'M365Advisor' -Parameters @{ testFolder = $testFolder; tenantId = $tenantId } {
                Get-MtM365AdvisorConfig -Path $testFolder -TenantId $tenantId
            }

            $result | Should -Not -BeNullOrEmpty
            $result.GlobalSettings.EmergencyAccessAccounts[0].UserPrincipalName | Should -Be 'BreakGlass@tenant-specific.com'
            $sample = $result.TestSettings | Where-Object Id -eq 'MT.1001'
            $sample.Severity | Should -Be 'Critical'
        }

        It 'Falls back to default config when TenantId has no matching file' {
            $otherTenantId = 'ffffffff-ffff-ffff-ffff-ffffffffffff'
            $result = InModuleScope -ModuleName 'M365Advisor' -Parameters @{ testFolder = $testFolder; otherTenantId = $otherTenantId } {
                Get-MtM365AdvisorConfig -Path $testFolder -TenantId $otherTenantId
            }

            $result | Should -Not -BeNullOrEmpty
            # Should get the default config, not the tenant-specific one
            $result.GlobalSettings.EmergencyAccessAccounts | Should -BeNullOrEmpty
        }

        It 'Sets ConfigSource to the tenant-specific filename' {
            $result = InModuleScope -ModuleName 'M365Advisor' -Parameters @{ testFolder = $testFolder; tenantId = $tenantId } {
                Get-MtM365AdvisorConfig -Path $testFolder -TenantId $tenantId
            }

            $result.ConfigSource | Should -Be "m365advisor-config.$tenantId.json"
        }

        It 'Sets ConfigSource to default filename when no tenant-specific config exists' {
            $otherTenantId = 'ffffffff-ffff-ffff-ffff-ffffffffffff'
            $result = InModuleScope -ModuleName 'M365Advisor' -Parameters @{ testFolder = $testFolder; otherTenantId = $otherTenantId } {
                Get-MtM365AdvisorConfig -Path $testFolder -TenantId $otherTenantId
            }

            $result.ConfigSource | Should -Be 'm365advisor-config.json'
        }

        It 'Ignores TenantId that is not a valid GUID' {
            $result = InModuleScope -ModuleName 'M365Advisor' -Parameters @{ testFolder = $testFolder } {
                Get-MtM365AdvisorConfig -Path $testFolder -TenantId 'not-a-guid'
            }

            $result | Should -Not -BeNullOrEmpty
            # Should fall back to default config
            $result.ConfigSource | Should -Be 'm365advisor-config.json'
        }

        It 'Uses direct file path when Path points to a file' {
            $result = InModuleScope -ModuleName 'M365Advisor' -Parameters @{ tenantConfigPath = $tenantConfigPath } {
                Get-MtM365AdvisorConfig -Path $tenantConfigPath
            }

            $result | Should -Not -BeNullOrEmpty
            # Should use the file directly, not search for m365advisor-config.json
            $result.GlobalSettings.EmergencyAccessAccounts[0].UserPrincipalName | Should -Be 'BreakGlass@tenant-specific.com'
        }

        AfterAll {
            Remove-Item -Path $tenantConfigPath -ErrorAction SilentlyContinue
        }
    }

    Context 'Using custom config' {
        It 'Merges custom config from <CustomFolderName>\m365advisor-config.json' -ForEach @(
            @{
                ScenarioName     = 'uppercase'
                CustomFolderName = 'Custom'
                AccountId        = '11111111-1111-1111-1111-111111111111'
            }
            @{
                ScenarioName     = 'lowercase'
                CustomFolderName = 'custom'
                AccountId        = '22222222-2222-2222-2222-222222222222'
            }
            @{
                ScenarioName     = 'mixedcase'
                CustomFolderName = 'CUSTOM'
                AccountId        = '33333333-3333-3333-3333-333333333333'
            }
        ) {
            $customTestFolder = Join-Path -Path 'TestDrive:' -ChildPath "m365advisor-config-tests-$ScenarioName"
            $null = New-Item -Path $customTestFolder -ItemType Directory -Force
            Copy-Item -Path (Join-Path -Path $m365advisorTestsPath -ChildPath 'm365advisor-config.json') -Destination (Join-Path -Path $customTestFolder -ChildPath 'm365advisor-config.json')

            $customFolderPath = Join-Path -Path $customTestFolder -ChildPath $CustomFolderName
            $null = New-Item -Path $customFolderPath -ItemType Directory -Force
            Set-Content -Path (Join-Path -Path $customFolderPath -ChildPath 'm365advisor-config.json') -Value (@{
                GlobalSettings = @{
                    EmergencyAccessAccounts = @(
                        @{
                            Type = 'User'
                            Id   = $AccountId
                        }
                    )
                }
                TestSettings   = @(
                    @{
                        Id       = 'MT.1001'
                        Severity = 'Info'
                        Title    = 'Overridden Title from Custom Config'
                    }
                )
            } | ConvertTo-Json -Depth 5)

            $result = InModuleScope -ModuleName 'M365Advisor' -Parameters @{ testFolder = $customTestFolder } {
                Get-MtM365AdvisorConfig -Path $testFolder
            }

            $result | Should -Not -BeNullOrEmpty
            $result.GlobalSettings | Should -Not -BeNullOrEmpty
            $result.TestSettings.Count | Should -BeGreaterThan 0

            $result.GlobalSettings | Should -Not -BeNullOrEmpty
            $result.GlobalSettings.EmergencyAccessAccounts.Count | Should -BeGreaterThan 0
            $result.GlobalSettings.EmergencyAccessAccounts[0].Type | Should -Be 'User'
            $result.GlobalSettings.EmergencyAccessAccounts[0].Id | Should -Be $AccountId

            $sample = $result.TestSettings | Where-Object Id -eq 'MT.1001'
            $sample.Severity | Should -Be 'Info'
            #$sample.Title | Should -Be 'Overridden Title from Custom Config'
        }
    }
}

