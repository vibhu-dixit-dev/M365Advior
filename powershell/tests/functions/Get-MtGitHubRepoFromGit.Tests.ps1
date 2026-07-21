Describe 'Get-MtGitHubRepoFromGit' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../M365Advisor.psd1 -Force
    }

    Context 'When git is not available' {
        It 'Returns $null when git command is not on PATH' {
            InModuleScope -ModuleName 'M365Advisor' {
                Mock Get-Command { $null } -ParameterFilter { $Name -eq 'git' }
                Get-MtGitHubRepoFromGit | Should -BeNullOrEmpty
            }
        }
    }

    Context 'When git remote is configured' {
        It 'Parses an HTTPS GitHub URL with .git suffix' {
            InModuleScope -ModuleName 'M365Advisor' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://github.com/m365advisor365/m365advisor.git' }

                $result = Get-MtGitHubRepoFromGit
                $result | Should -Not -BeNullOrEmpty
                $result.Organization | Should -Be 'm365advisor365'
                $result.Repository   | Should -Be 'm365advisor'
            }
        }

        It 'Parses an HTTPS GitHub URL without .git suffix' {
            InModuleScope -ModuleName 'M365Advisor' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://github.com/contoso/security-tests' }

                $result = Get-MtGitHubRepoFromGit
                $result.Organization | Should -Be 'contoso'
                $result.Repository   | Should -Be 'security-tests'
            }
        }

        It 'Parses an SSH (scp-style) GitHub URL' {
            InModuleScope -ModuleName 'M365Advisor' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'git@github.com:fabrikam/m365advisor-tests.git' }

                $result = Get-MtGitHubRepoFromGit
                $result.Organization | Should -Be 'fabrikam'
                $result.Repository   | Should -Be 'm365advisor-tests'
            }
        }

        It 'Parses an ssh:// GitHub URL' {
            InModuleScope -ModuleName 'M365Advisor' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'ssh://git@github.com/contoso/repo.git' }

                $result = Get-MtGitHubRepoFromGit
                $result.Organization | Should -Be 'contoso'
                $result.Repository   | Should -Be 'repo'
            }
        }

        It 'Returns $null for non-GitHub remotes' {
            InModuleScope -ModuleName 'M365Advisor' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://dev.azure.com/contoso/_git/repo' }

                Get-MtGitHubRepoFromGit | Should -BeNullOrEmpty
            }
        }

        It 'Returns $null when git remote returns nothing' {
            InModuleScope -ModuleName 'M365Advisor' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { '' }

                Get-MtGitHubRepoFromGit | Should -BeNullOrEmpty
            }
        }

        It 'Returns $null for a lookalike host that ends with github.com (e.g. evilgithub.com)' {
            InModuleScope -ModuleName 'M365Advisor' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://evilgithub.com/owner/repo.git' }

                Get-MtGitHubRepoFromGit | Should -BeNullOrEmpty
            }
        }

        It 'Returns $null for a host that has github.com as a subdomain prefix (e.g. github.com.attacker.com)' {
            InModuleScope -ModuleName 'M365Advisor' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://github.com.attacker.com/owner/repo.git' }

                Get-MtGitHubRepoFromGit | Should -BeNullOrEmpty
            }
        }

        It 'Returns $null for a hyphenated lookalike (e.g. my-github.com)' {
            InModuleScope -ModuleName 'M365Advisor' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://my-github.com/owner/repo.git' }

                Get-MtGitHubRepoFromGit | Should -BeNullOrEmpty
            }
        }

        It 'Parses an HTTPS GitHub URL with www. prefix' {
            InModuleScope -ModuleName 'M365Advisor' {
                Mock Get-Command { @{ Name = 'git' } } -ParameterFilter { $Name -eq 'git' }
                Mock git { 'https://www.github.com/contoso/repo.git' }

                $result = Get-MtGitHubRepoFromGit
                $result.Organization | Should -Be 'contoso'
                $result.Repository   | Should -Be 'repo'
            }
        }
    }
}

