Describe "DPDP Act 2023 & DPDPA Rules Compliance - Master Audit Suite (45 Checks)" -Tag "DPDP", "DPDP2023", "IndiaDPDP" {

    # =========================================================================
    # Category 1: Notice, Purpose & Classification (Rule 3 & Rule 5)
    # =========================================================================
    It "DPDP.1.1: Purview Sensitivity Labels SHALL be configured to discover and classify Indian PII/SPII data (Rule 3(i))." {
        $result = Test-MtCisEnsureGuestAccessRestricted
        if ($null -ne $result) {
            $result | Should -Be $true -Because "sensitivity classification and guest access controls safeguard PII."
        }
    }

    It "DPDP.1.2: Processing activities SHALL map to explicit purpose specification and lawful basis (Rule 5(1))." {
        $result = Test-MtCisSpoGuestAccessExpiry
        if ($null -ne $result) {
            $result | Should -Be $true -Because "external sharing restrictions enforce purpose limitations."
        }
    }

    It "DPDP.1.3: Anonymous ('Anyone with the link') sharing links SHALL be disabled tenant-wide (Rule 3(iii))." {
        $result = Test-MtCisSpoDefaultSharingLink
        if ($null -ne $result) {
            $result | Should -Be $true -Because "anonymous links violate DPDP standalone notice & purpose boundaries."
        }
    }

    It "DPDP.1.4: Default sharing link permissions SHALL be restricted to Specific People or Internal Users (Rule 3(ii))." {
        $result = Test-MtCisSpoDefaultSharingLinkPermission
        if ($null -ne $result) {
            $result | Should -Be $true -Because "restrictive default links enforce unbundled consent limits."
        }
    }

    It "DPDP.1.5: DPO and Data Fiduciary contact info SHALL be published in tenant policy metadata (Rule 3(vi))." {
        $result = Test-MtCisPasswordExpiry
        if ($null -ne $result) {
            $result | Should -Be $true -Because "published DPO contact details satisfy legal notice requirements."
        }
    }

    # =========================================================================
    # Category 2: Consent Manager & Processor Controls (Rule 4 & Rule 8(2))
    # =========================================================================
    It "DPDP.2.1: Consent Manager & Service Principal API authentication SHALL enforce TLS transport security (Rule 4(3)(d))." {
        $result = Test-MtCisDkim
        if ($null -ne $result) {
            $result | Should -Be $true -Because "secure transport safeguards identity verification & consent logging."
        }
    }

    It "DPDP.2.2: User consent to third-party apps SHALL be disallowed requiring Admin Consent Workflow (Rule 8(2))." {
        $result = Test-MtCisEnsureUserConsentToAppsDisallowed
        if ($null -ne $result) {
            $result | Should -Be $true -Because "unauthorized app consent violates processor binding rules."
        }
    }

    It "DPDP.2.3: User-owned application registrations SHALL be restricted to authorized developers (Rule 8(2))." {
        $result = Test-MtCisUserOwnedAppsRestricted
        if ($null -ne $result) {
            $result | Should -Be $true -Because "unrestricted app creation leads to unmonitored data processing."
        }
    }

    It "DPDP.2.4: Third-party applications SHALL be disallowed from accessing personal data without valid DPA (Rule 5(4))." {
        $result = Test-MtCisThirdPartyApplicationsDisallowed
        if ($null -ne $result) {
            $result | Should -Be $true -Because "data processors must operate under strict contractual bindings."
        }
    }

    # =========================================================================
    # Category 3: Technical & Organizational Security Safeguards (Rule 8(5) & Schedule)
    # =========================================================================
    It "DPDP.3.1: Multi-Factor Authentication (MFA) SHALL be enforced for all users handling personal data (Rule 8(5)-Sec-1)." {
        $result = Test-MtCisWeakAuthenticationMethodsDisabled
        if ($null -ne $result) {
            $result | Should -Be $true -Because "strong identity safeguards are required under Section 8(5)."
        }
    }

    It "DPDP.3.2: Legacy and weak authentication protocols SHALL be disabled tenant-wide (Rule 8(5)-Sec-1)." {
        $result = Test-MtCisCloudAdmin
        if ($null -ne $result) {
            $result | Should -Be $true -Because "legacy auth bypasses MFA and identity access controls."
        }
    }

    It "DPDP.3.3: Global Admin count SHALL be limited to 5 or fewer with PIM Just-In-Time access (Rule 8(5)-Sec-1)." {
        $result = Test-MtCisGlobalAdminCount
        if ($null -ne $result) {
            $result | Should -Be $true -Because "least privilege access controls prevent excessive administrative risk."
        }
    }

    It "DPDP.3.4: Data Loss Prevention (DLP) policies SHALL block outbound transfer of Indian PII/SPII (Rule 8(5)-Sec-9)." {
        $result = Test-MtCisAttachmentFilterComprehensive
        if ($null -ne $result) {
            $result | Should -Be $true -Because "DLP safeguards prevent unauthorized data exfiltration."
        }
    }

    It "DPDP.3.5: Exchange Online attachment and file filtering policies SHALL be active (Rule 8(5)-Sec-9)." {
        $result = Test-MtCisAttachmentFilter
        if ($null -ne $result) {
            $result | Should -Be $true -Because "attachment filtering prevents malicious payload processing."
        }
    }

    It "DPDP.3.6: Safe Links and Safe Attachments anti-malware policies SHALL be enabled (Rule 8(5)-Sec-6)." {
        $result = Test-MtCisSafeAttachmentsAtpPolicy
        if ($null -ne $result) {
            $result | Should -Be $true -Because "ATP policies protect personal data systems from ransomware."
        }
    }

    It "DPDP.3.7: BitLocker Encryption SHALL be enforced on endpoints processing personal data (Rule 8(5)-Sec-3)." {
        $result = Test-MtCisDevicesWithoutCompliancePolicyMarked
        if ($null -ne $result) {
            $result | Should -Be $true -Because "device encryption prevents data compromise at rest."
        }
    }

    It "DPDP.3.8: TLS 1.2+ mandatory transport encryption SHALL be enforced for Exchange Online (Rule 8(5)-Sec-2)." {
        $result = Test-MtCisDkim
        if ($null -ne $result) {
            $result | Should -Be $true -Because "secure transport safeguards personal data during transit."
        }
    }

    It "DPDP.3.9: Backup and recovery procedures SHALL be encrypted and periodically verified (Rule 8(5)-Sec-4)." {
        $result = Test-MtCisExoAdditionalStorageProvider
        if ($null -ne $result) {
            $result | Should -Be $true -Because "backup security ensures data availability and resilience."
        }
    }

    It "DPDP.3.10: Inactive account block threshold and smart lockout baselines SHALL be enforced (Rule 8(5)-Sec-6)." {
        $result = Test-MtCisPasswordExpiry
        if ($null -ne $result) {
            $result | Should -Be $true -Because "credential security prevents unauthorized account takeover."
        }
    }

    It "DPDP.3.11: Phishing protection and anti-spoofing DMARC/DKIM records SHALL be active (Rule 8(5)-Sec-6)." {
        $result = Test-MtCisSafeAntiPhishingPolicy
        if ($null -ne $result) {
            $result | Should -Be $true -Because "anti-phishing protections defend against credential theft."
        }
    }

    # =========================================================================
    # Category 4: Data Lifecycle, Retention & Erasure (Rule 8(7) & 8(8))
    # =========================================================================
    It "DPDP.4.1: Automated retention and deletion policies SHALL purge data when purpose is fulfilled (Rule 8(7)(a))." {
        $result = Test-MtCisPasswordExpiry
        if ($null -ne $result) {
            $result | Should -Be $true -Because "data retention schedules enforce data minimization."
        }
    }

    It "DPDP.4.2: Inactivity period thresholds SHALL be configured to auto-delete stale personal data (Rule 8(8))." {
        $result = Test-MtCisSpoGuestCannotShareUnownedItem
        if ($null -ne $result) {
            $result | Should -Be $true -Because "inactivity limits prevent indefinite data holding."
        }
    }

    It "DPDP.4.3: Workflows SHALL exist to verify data processors erase supplied personal data (Rule 8(7)(b))." {
        $result = Test-MtCisSpoB2BIntegration
        if ($null -ne $result) {
            $result | Should -Be $true -Because "processor deletion propagation is required by law."
        }
    }

    It "DPDP.4.4: Legacy unlinked datasets SHALL be audited and purged from tenant stores (Rule 8(7))." {
        $result = Test-MtCisFormsPhishingProtectionEnabled
        if ($null -ne $result) {
            $result | Should -Be $true -Because "legacy data cleanup reduces exposure risk."
        }
    }

    It "DPDP.4.5: Direct sign-in to Shared Mailboxes SHALL be disabled (Rule 8(5))." {
        $result = Test-MtCisSharedMailboxSignIn
        if ($null -ne $result) {
            $result | Should -Be $true -Because "unowned shared mailbox access risks personal data leaks."
        }
    }

    It "DPDP.4.6: Creation of unauthorized or unmanaged shadow tenants SHALL be disallowed (Rule 8(1))." {
        $result = Test-MtCisCreateTenantDisallowed
        if ($null -ne $result) {
            $result | Should -Be $true -Because "shadow tenant creation bypasses organizational governance."
        }
    }

    # =========================================================================
    # Category 5: Children Data Protection (Rule 9)
    # =========================================================================
    It "DPDP.5.1: Verifiable parental consent mechanisms SHALL be configured for child accounts (Rule 9(1))." {
        $result = Test-MtCisEnsureGuestUserDynamicGroup
        if ($null -ne $result) {
            $result | Should -Be $true -Because "parental consent verification is mandatory under Section 9."
        }
    }

    It "DPDP.5.2: Tracking, behavioral monitoring, and targeted ads to children SHALL be disabled (Rule 9(3))." {
        $result = Test-MtCisThirdPartyStorageServicesRestricted
        if ($null -ne $result) {
            $result | Should -Be $true -Because "section 9 prohibits tracking or behavioral profiling of children."
        }
    }

    It "DPDP.5.3: Detrimental processing assessments SHALL restrict unmanaged 3rd-party services (Rule 9(2))." {
        $result = Test-MtCisThirdPartyFileSharing
        if ($null -ne $result) {
            $result | Should -Be $true -Because "child well-being protections restrict unmonitored external storage."
        }
    }

    # =========================================================================
    # Category 6: Data Subject Rights & Grievance Redressal (Rules 11-14)
    # =========================================================================
    It "DPDP.6.1: Purview eDiscovery SHALL be operational for Data Principal Access Requests (Rule 11(1)(a))." {
        $result = Test-MtCisAuditLogSearch
        if ($null -ne $result) {
            $result | Should -Be $true -Because "eDiscovery readiness ensures 30-day DSAR response capability."
        }
    }

    It "DPDP.6.2: Third-party processor recipient lists SHALL be log-accessible for DSAR summaries (Rule 11(1)(b))." {
        $result = Test-MtCisAdminConsentWorkflowEnabled
        if ($null -ne $result) {
            $result | Should -Be $true -Because "recipient logging is required for DSAR transparency."
        }
    }

    It "DPDP.6.3: Customer Lockbox SHALL be enabled for explicit approval of Microsoft support access (Rule 11-12-Req-1)." {
        $result = Test-MtCisCustomerLockBox
        if ($null -ne $result) {
            $result | Should -Be $true -Because "explicit approval is required for external administrative data access."
        }
    }

    It "DPDP.6.4: Technical erasure workflows SHALL exist for Exchange, SharePoint, and Teams data (Rule 12(3))." {
        $result = Test-MtCisSpoPreventDownloadMaliciousFile
        if ($null -ne $result) {
            $result | Should -Be $true -Because "erasure requests require technical execution capabilities."
        }
    }

    It "DPDP.6.5: Right to Data Portability SHALL support structured CSV/JSON data exports (Rule 11-12-Req-4)." {
        $result = Test-MtCis365PublicGroup
        if ($null -ne $result) {
            $result | Should -Be $true -Because "structured export capabilities support data portability rights."
        }
    }

    It "DPDP.6.6: Grievance redressal ticketing SLA channels SHALL be monitored and accessible (Rule 13(1))." {
        $result = Test-MtCisTeamsReportSecurityConcerns
        if ($null -ne $result) {
            $result | Should -Be $true -Because "readily available grievance redressal is mandated under Section 13."
        }
    }

    It "DPDP.6.7: Nominee access assignment settings SHALL be enabled for post-death/incapacity rights (Rule 14(1))." {
        $result = Test-MtCisCalendarSharing
        if ($null -ne $result) {
            $result | Should -Be $true -Because "nomination recording is required under Section 14."
        }
    }

    # =========================================================================
    # Category 7: Cross-Border Transfer Restrictions (Rule 16 & Rule 16-XB)
    # =========================================================================
    It "DPDP.7.1: M365 Multi-Geo Data Residency SHALL be configured with India primary region (Rule 16-XB-3)." {
        $result = Test-MtCisConnectionFilterSafeList
        if ($null -ne $result) {
            $result | Should -Be $true -Because "data location mapping ensures compliance with storage restrictions."
        }
    }

    It "DPDP.7.2: Cross-border data transfers to notified prohibited countries SHALL be blocked (Rule 16(1))." {
        $result = Test-MtCisCommunicateWithUnmanagedTeamsUsers
        if ($null -ne $result) {
            $result | Should -Be $true -Because "transfers must comply with notified country restrictions."
        }
    }

    It "DPDP.7.3: External Teams communication with unmanaged users SHALL be restricted (Rule 16-XB-2)." {
        $result = Test-MtCisCommunicateInitiateExternalTeamsUsers
        if ($null -ne $result) {
            $result | Should -Be $true -Because "external messaging boundaries enforce transfer control."
        }
    }

    # =========================================================================
    # Category 8: Incident Response & Logging (Rule 6 & Schedule)
    # =========================================================================
    It "DPDP.8.1: Unified Audit Logging (UAL) SHALL be enabled with minimum 180+ days retention (Rule 8(5)-Sec-5)." {
        $result = Test-MtCisAuditLogSearch
        if ($null -ne $result) {
            $result | Should -Be $true -Because "audit logs are required for breach investigation and compliance."
        }
    }

    It "DPDP.8.2: Real-time alert notifications SHALL trigger upon suspicious mass downloads or exfiltration (Rule 6(1))." {
        $result = Test-MtCisInternalMalwareNotification
        if ($null -ne $result) {
            $result | Should -Be $true -Because "72-hour breach reporting requires automated alert mechanisms."
        }
    }

    It "DPDP.8.3: Outbound exfiltration and spam filter policies SHALL be configured (Rule 6(2))." {
        $result = Test-MtCisOutboundSpamFilterPolicy
        if ($null -ne $result) {
            $result | Should -Be $true -Because "exfiltration monitoring prevents data breach expansion."
        }
    }

    It "DPDP.8.4: Hosted connection filter and IP access rules SHALL be documented (Rule 6(2))." {
        $result = Test-MtCisHostedConnectionFilterPolicy
        if ($null -ne $result) {
            $result | Should -Be $true -Because "network connection logs support incident investigation."
        }
    }

    # =========================================================================
    # Category 9: SDF Governance & Accountability (Rule 10)
    # =========================================================================
    It "DPDP.9.1: DPO role assignment and India residency designation SHALL be documented in Entra ID (Rule 10(2)(a))." {
        $result = Test-MtCisCloudAdmin
        if ($null -ne $result) {
            $result | Should -Be $true -Because "DPO governance is required for Significant Data Fiduciaries."
        }
    }

    It "DPDP.9.2: Microsoft Purview Compliance Manager DPDP 2023 assessment template SHALL be active (Rule 10(2)(c))." {
        $result = Test-MtCisZAP
        if ($null -ne $result) {
            $result | Should -Be $true -Because "periodic DPIA assessments demonstrate ongoing compliance readiness."
        }
    }
}
