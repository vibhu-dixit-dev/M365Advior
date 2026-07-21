# M365Advisor Tests

This folder contains the tests that M365Advisor will run to validate your environment. The tests are organized into the following folders:

- **Custom**: Place your custom Pester tests in this directory. The file name should end with `.Tests.ps1`.
- **CIS**: Contains the tests that verifies the tenant's configuration conforms to the guidelines identified by the [Center for Internet Security (CIS) benchmark](https://www.cisecurity.org/benchmark/microsoft_365).
- **CISA**: Contains the tests that verifies the tenant’s configuration conforms to the policies described in the Secure Cloud Business Applications ([SCuBA](https://cisa.gov/scuba)) Security Configuration Baseline [documents](https://github.com/cisagov/ScubaGear/blob/main/baselines/README.md).
- **EIDSCA**: Contains tests based on the [Entra ID Security Config Analyzer](https://m365advisor.dev/docs/tests/eidsca/).
- **M365Advisor**: Contains the tests that are built by the M365Advisor team with contributions from the community. To learn more about the tests see [M365Advisor Tests](https://m365advisor.dev/docs/tests/m365advisor).

## Running M365Advisor

To run the tests in this folder run the following PowerShell commands. To learn more see [m365advisor.dev](https://m365advisor.dev).

```powershell
Connect-M365Advisor
Invoke-M365Advisor
```

## Keeping your M365Advisor tests up to date

The M365Advisor team will add new tests over time. To get the latest updates, use the commands below to update this folder with the latest tests.

- Update the `M365Advisor` PowerShell module to the latest version and load it.
- Change to the folder that has the tests.
- Run `Update-M365AdvisorTests`.

```powershell
Update-Module M365Advisor -Force
Import-Module M365Advisor
Update-M365AdvisorTests
```

## Customizing Severity Levels

### Customizing Severity Levels for Out of the Box Tests

You can customize the severity levels of the out of the box tests tests.

To do this create a file named `m365advisor-config.json` in your `./Custom` folder.

Provide the severity levels for the tests you want to customize, using the format below.

The severity levels are:

- Critical
- High
- Medium
- Low
- Info

```json
{
    "TestSettings": [
        {
            "Id": "CIS.M365.1.1.1",
            "Severity": "High"
        }
    ]
}
```

### Defining severity levels for custom tests

You can define severity levels for your custom tests using the above approach (`m365advisor-config.json`) or by using the `-Tag` parameter in the `Describe` or `It` block of your Pester tests.

The tag needs to be in the format of `Severity:<SeverityLevel>`.

E.g.

```powershell
Describe 'My Custom Test' {
    It 'Cus.1001: My custom test' -Tag 'Severity:High' {
        # Your test code here
    }
}
```

If a Severity level is defined in both the `m365advisor-config.json` file and the test, the one in the `./Custom/m365advisor-config.json` will take precedence.

