## PowerShell Summary

The M365Advisor project is structured to keep the code organized and maintainable. The `powershell` directory holds all PowerShell-related code, with `internal` for internal utilities and `tests` for testing purposes.

## Folder Structure

This directory contains PowerShell-related scripts and modules.

#### assets/
A subdirectory for templates and other related "general" files.

#### internal/
A subdirectory for internal scripts and functions used by the M365Advisor project. These scripts are not meant to be accessed directly by end users.

#### public/
A subdirectory that contains scripts and functions meant to be accessed directly by end users like the Cmdlet **Invoke-M365Advisor**. These scripts provide the main functionality and features of the M365Advisor project.

#### tests/
A subdirectory that contains test scripts. These scripts are used to verify the functionality and reliability of the M365Advisor project.

## Module structure

### M365Advisor.psd1
This is the PowerShell module manifest file for the M365Advisor project. It contains metadata about the module, such as its version, author, and dependencies.

### M365Advisor.psm1
This is the PowerShell module file for the M365Advisor project. It contains the implementation of the functions and cmdlets provided by the M365Advisor module.

The `M365Advisor.psd1` and `M365Advisor.psm1` files at the root define the module's metadata and implementation, respectively.
