---
sidebar_position: 7
title: ❓ FAQ
---

## Is this a Microsoft product?

No. M365Advisor is an open-source, community led project and is not affiliated with Microsoft.

## How do I report issues?

If you encounter an issue with M365Advisor, please [open an issue on GitHub](https://github.com/m365advisor365/m365advisor/issues).

## Previously installed 'Pester' version '3.4.0' conflicts with new module

If you see the following error when installing M365Advisor, it means that you have an older version of Pester installed.

**A Microsoft-signed module named 'Pester' with version '3.4.0' that was previously installed conflicts with the new module 'Pester'**

Run the following command to install the latest version of Pester and then retry installing M365Advisor.

```powershell
Install-Module Pester -Scope CurrentUser -SkipPublisherCheck -Force
```

To learn more or if you run into Pester installation issues see [Pester Installation and Update](https://pester.dev/docs/introduction/installation)


