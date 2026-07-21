---
title: M365Advisor results on Azure Web App!
description: M365Advisor deployed to a Azure WebApp using Azure DevOps
slug: m365advisor-with-azdo-webapp
authors: sebastian
tags: [AzureDevOps,WebApp,Bicep]
hide_table_of_contents: false
date: 2025-03-27
image: ./img/azure-devops-webapp-diagram.png
#draft: true # Draft
#unlisted: true # https://github.com/facebook/docusaurus/pull/1396#issuecomment-487561180
---

We are excited to announce that you can now deploy your M365Advisor results (using Azure DevOps) to a web app in Azure! 🚀

Teams using Azure DevOps pipelines can now easily integrate M365Advisor into their CI/CD workflows to run automated security checks and enhance their security monitoring on a daily basis.

Utiziling an Azure web app providing access to the results using Entra id as authentication.

<!-- truncate -->

## Azure DevOps Web App Flowchart

![M365Advisor Azure DevOps](img/azure-devops-webapp-diagram.png)

### Quick Stats

- 🚀 Automated security tests using Azure DevOps Pipelines updated every 12th hour by default
- 🔥 Up and running within 10 minutes
- 🤝 Viewable M365Advisor reports using Azure Web App
- 🔐 Pipeline with authentication support for Exchange Online, ISSP (using certificate based authentication) and Microsoft Teams

### Get Started

Follow the step-by-step guide to set up M365Advisor in Azure DevOps with required resources:

- Documentation: [Set up M365Advisor in Azure DevOps with Web App](/docs/monitoring/azure-devops-web-app-bicep)

## Contributor

- [Sebastian Claesson](/blog/authors/sebastian)

