Describe 'Test-MtExoModernAuth' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../M365Advisor.psd1 -Force
        Mock -ModuleName M365Advisor Test-MtConnection { return $true }
    }

    Context 'Modern authentication enabled (boolean $true)' {
        BeforeAll {
            Mock -ModuleName M365Advisor Get-MtExo {
                return [PSCustomObject]@{
                    OAuth2ClientProfileEnabled = $true
                }
            }
        }

        It 'Should return $true when OAuth2ClientProfileEnabled is $true' {
            Test-MtExoModernAuth | Should -BeTrue
        }
    }

    Context 'Modern authentication disabled (boolean $false)' {
        BeforeAll {
            Mock -ModuleName M365Advisor Get-MtExo {
                return [PSCustomObject]@{
                    OAuth2ClientProfileEnabled = $false
                }
            }
        }

        It 'Should return $false when OAuth2ClientProfileEnabled is $false' {
            Test-MtExoModernAuth | Should -BeFalse
        }
    }

    Context 'Modern authentication enabled (string "True")' {
        BeforeAll {
            Mock -ModuleName M365Advisor Get-MtExo {
                return [PSCustomObject]@{
                    OAuth2ClientProfileEnabled = 'True'
                }
            }
        }

        It 'Should return $true when OAuth2ClientProfileEnabled is the string "True"' {
            Test-MtExoModernAuth | Should -BeTrue
        }
    }

    Context 'Modern authentication disabled (string "False")' {
        BeforeAll {
            Mock -ModuleName M365Advisor Get-MtExo {
                return [PSCustomObject]@{
                    OAuth2ClientProfileEnabled = 'False'
                }
            }
        }

        It 'Should return $false when OAuth2ClientProfileEnabled is the string "False"' {
            Test-MtExoModernAuth | Should -BeFalse
        }
    }
}

