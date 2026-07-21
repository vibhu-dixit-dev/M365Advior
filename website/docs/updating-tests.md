---
title: 🧪 Updating tests
---

# Updating your M365Advisor tests

The M365Advisor team will add new tests over time. To get the latest updates, use the commands below to update your GitHub repository with the latest tests.

### Step 1: Change to the folder with your tests

Open a command prompt and navigate to the folder where you have your M365Advisor tests.

```powershell
cd m365advisor-tests
```

### Step 2: Update the M365Advisor module

Update the **M365Advisor** PowerShell module to the latest version and load it.

```powershell
Update-Module M365Advisor -Force
Import-Module M365Advisor
```

### Step 3: Update the tests folder

You will be prompted to confirm changes to the tests folder.

* All of your custom tests in the `/Custom` folder will be preserved.
* The test files in the other folders including `/EIDSCA`, `/M365Advisor` and `/CISA` will be overwritten with the latest tests.

```powershell
Update-M365AdvisorTests
```

:::note

If you are not seeing the latest tests, try closing and reopening your PowerShell session after completing **Step 2** (`Update-Module`).

:::

