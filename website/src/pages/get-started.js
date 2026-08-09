import React, { useState, useEffect, useRef } from 'react';
import { useLocation } from '@docusaurus/router';
import clsx from 'clsx';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import useBaseUrl from '@docusaurus/useBaseUrl';
import styles from './get-started.module.css';

const frameworks = [
  /*
  {
    id: "m365",
    title: "M365 Advisor Baselines",
    subtitle: "Best-practice security tests for posture",
    desc: "170+ automated checks validating authentication strength, conditional access, administration settings, and external sharing policies.",
    accent: "#ff7a7a",
    glow: "rgba(255, 122, 122, 0.15)",
    icon: "🔥",
    tag: "M365 Posture",
    setupCmd: "Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser\nInstall-Module M365Advisor -Scope CurrentUser\n\nmd M365Advisor-tests\ncd M365Advisor-tests\nInstall-M365AdvisorTests",
    connectCmd: "Connect-M365Advisor",
    runCmd: "Invoke-M365Advisor"
  },
  {
    id: "eidsca",
    title: "Entra ID SCA",
    subtitle: "Identity attack & defense playbook checks",
    desc: "40+ checks analyzing tenant configuration against common Entra ID attack vectors, privilege escalation paths, and bypass scenarios.",
    accent: "#00f2fe",
    glow: "rgba(0, 242, 254, 0.15)",
    icon: "🛡️",
    tag: "Entra Security",
    setupCmd: "Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser\nInstall-Module M365Advisor -Scope CurrentUser\n\nmd M365Advisor-tests\ncd M365Advisor-tests\nInstall-M365AdvisorTests",
    connectCmd: "Connect-M365Advisor",
    runCmd: "Invoke-M365Advisor"
  },
  {
    id: "cisa",
    title: "CISA SCuBA Baselines",
    subtitle: "Federal cloud security benchmarks",
    desc: "Hardened tenant validation rules matching CISA Secure Cloud Business Applications guidelines for high-value government and enterprise assets.",
    accent: "#c084fc",
    glow: "rgba(192, 132, 252, 0.15)",
    icon: "🦅",
    tag: "CISA SCuBA",
    setupCmd: "Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser\nInstall-Module M365Advisor -Scope CurrentUser\n\nmd M365Advisor-tests\ncd M365Advisor-tests\nInstall-M365AdvisorTests",
    connectCmd: "Connect-M365Advisor",
    runCmd: "Invoke-M365Advisor"
  },
  */
  {
    id: "cis",
    title: "CIS Benchmarks",
    subtitle: "Foundations benchmark certification mapping",
    desc: "Over 44+ automated controls mapped to CIS Microsoft 365 Foundations Benchmark Levels 1 and 2 guidelines for defense-in-depth.",
    accent: "#fb923c",
    glow: "rgba(251, 146, 60, 0.15)",
    icon: "🌀",
    tag: "CIS Benchmark",
    keywords: ["cis", "benchmark", "foundations", "microsoft 365", "cis benchmark"],
    setupCmd: "Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser -AllowClobber\nInstall-Module Audit365 -Scope CurrentUser -Force -AllowClobber\n\nif (-not (Test-Path M365Advisor-tests)) { md M365Advisor-tests }\ncd M365Advisor-tests\nInstall-M365AdvisorTests -Force",
    connectCmd: "Connect-M365Advisor",
    runCmd: "Invoke-M365Advisor -Tag 'CIS'"
  },
  {
    id: "iso27001",
    title: "ISO/IEC 27001:2022",
    subtitle: "Information Security Management System",
    desc: "44 controls mapped to the international standard for information security (ISMS).",
    accent: "#059669",
    glow: "rgba(5, 150, 105, 0.15)",
    icon: "🌐",
    tag: "ISO 27001",
    keywords: ["iso", "iso27001", "iso 27001", "isms", "information security", "27001"],
    setupCmd: "Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser -AllowClobber\nInstall-Module Audit365 -Scope CurrentUser -Force -AllowClobber\n\nif (-not (Test-Path M365Advisor-tests)) { md M365Advisor-tests }\ncd M365Advisor-tests\nInstall-M365AdvisorTests -Force",
    connectCmd: "Connect-M365Advisor",
    runCmd: "Invoke-M365Advisor -Path .\\iso27001"
  },
  {
    id: "iso27002",
    title: "ISO/IEC 27002:2022",
    subtitle: "Security Controls Guidance",
    desc: "44 controls mapped to ISO 27002 implementation guidelines for security controls.",
    accent: "#0d9488",
    glow: "rgba(13, 148, 136, 0.15)",
    icon: "📋",
    tag: "ISO 27002",
    keywords: ["iso", "iso27002", "iso 27002", "security controls", "27002"],
    setupCmd: "Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser -AllowClobber\nInstall-Module Audit365 -Scope CurrentUser -Force -AllowClobber\n\nif (-not (Test-Path M365Advisor-tests)) { md M365Advisor-tests }\ncd M365Advisor-tests\nInstall-M365AdvisorTests -Force",
    connectCmd: "Connect-M365Advisor",
    runCmd: "Invoke-M365Advisor -Path .\\iso27002"
  },
  {
    id: "cisa",
    title: "CISA SCuBA Baselines",
    subtitle: "Federal Cloud Security Benchmarks",
    desc: "Hardened tenant validation rules matching CISA Secure Cloud Business Applications guidelines for high-value assets.",
    accent: "#c084fc",
    glow: "rgba(192, 132, 252, 0.15)",
    icon: "🦅",
    tag: "CISA SCuBA",
    keywords: ["cisa", "scuba", "cisa scuba", "federal", "cloud security"],
    setupCmd: "Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser -AllowClobber\nInstall-Module Audit365 -Scope CurrentUser -Force -AllowClobber\n\nif (-not (Test-Path M365Advisor-tests)) { md M365Advisor-tests }\ncd M365Advisor-tests\nInstall-M365AdvisorTests -Force",
    connectCmd: "Connect-M365Advisor",
    runCmd: "Invoke-M365Advisor -Tag 'CISA'"
  },
  {
    id: "eidsca",
    title: "Entra ID SCA",
    subtitle: "Identity Attack & Defense Playbook Checks",
    desc: "40+ checks analyzing tenant configuration against common Entra ID attack vectors, privilege escalation paths, and bypass scenarios.",
    accent: "#00f2fe",
    glow: "rgba(0, 242, 254, 0.15)",
    icon: "🛡️",
    tag: "EIDSCA",
    keywords: ["eidsca", "eidsa", "entra id", "entra", "identity", "sca"],
    setupCmd: "Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser -AllowClobber\nInstall-Module Audit365 -Scope CurrentUser -Force -AllowClobber\n\nif (-not (Test-Path M365Advisor-tests)) { md M365Advisor-tests }\ncd M365Advisor-tests\nInstall-M365AdvisorTests -Force",
    connectCmd: "Connect-M365Advisor",
    runCmd: "Invoke-M365Advisor -Tag 'EIDSCA'"
  },
  {
    id: "mt",
    title: "M365 Advisor Baselines (MT)",
    subtitle: "Best-Practice Security Posture Baselines",
    desc: "170+ automated checks validating authentication strength, conditional access, administration settings, and external sharing policies.",
    accent: "#ff7a7a",
    glow: "rgba(255, 122, 122, 0.15)",
    icon: "🔥",
    tag: "MT Baseline",
    keywords: ["mt", "m365", "microsoft tenant", "tenant security", "baselines", "posture"],
    setupCmd: "Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser -AllowClobber\nInstall-Module Audit365 -Scope CurrentUser -Force -AllowClobber\n\nif (-not (Test-Path M365Advisor-tests)) { md M365Advisor-tests }\ncd M365Advisor-tests\nInstall-M365AdvisorTests -Force",
    connectCmd: "Connect-M365Advisor",
    runCmd: "Invoke-M365Advisor"
  },
  {
    id: "hippa",
    title: "HIPPA",
    subtitle: "Healthcare Security & Privacy Baseline",
    desc: "Automated controls mapping your tenant's security, privacy, and breach notification policies to HIPAA compliance rules.",
    accent: "#fb923c",
    glow: "rgba(251, 146, 60, 0.15)",
    icon: "🩺",
    tag: "HIPPA",
    keywords: ["hippa", "hipaa", "healthcare", "privacy", "health"],
    isPremium: true
  },
  {
    id: "rbi-nbfc",
    title: "RBI NBFC",
    subtitle: "RBI Master Directions for NBFCs",
    desc: "Checks validating IT governance, information security policy, cyber security controls, and vendor risk management.",
    accent: "#fb923c",
    glow: "rgba(251, 146, 60, 0.15)",
    icon: "🏦",
    tag: "RBI NBFC",
    keywords: ["rbi", "nbfc", "reserve bank", "india", "financial"],
    isPremium: true
  },
  {
    id: "dpdp",
    title: "DPDP Act 2023",
    subtitle: "Digital Personal Data Protection Act",
    desc: "Audit rules checking consent management systems, data principal rights, erasure protocols, and fiduciary responsibilities.",
    accent: "#fb923c",
    glow: "rgba(251, 146, 60, 0.15)",
    icon: "⚖️",
    tag: "DPDP 2023",
    keywords: ["dpdp", "digital personal data", "data protection", "privacy act", "india"],
    isPremium: true
  },
  /*
  {
    id: "orca",
    title: "ORCA Exchange Hygiene",
    subtitle: "Exchange Online analyzer baseline",
    desc: "60+ critical security hygiene rules validating mail flow rules, anti-phishing, safe attachments, and email authentication standards.",
    accent: "#2dd4bf",
    glow: "rgba(45, 212, 191, 0.15)",
    icon: "🐋",
    tag: "ORCA Exchange",
    setupCmd: "Install-Module Pester -SkipPublisherCheck -Force -Scope CurrentUser\nInstall-Module M365Advisor -Scope CurrentUser\n\nmd M365Advisor-tests\ncd M365Advisor-tests\nInstall-M365AdvisorTests",
    connectCmd: "Connect-M365Advisor",
    runCmd: "Invoke-M365Advisor"
  }
  */
];

function CopyButton({ text }) {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <button
      className={clsx(styles.copyButton, copied && styles.copyButtonSuccess)}
      onClick={handleCopy}
      type="button"
    >
      {copied ? (
        <>
          <span>✓</span> Copied!
        </>
      ) : (
        <>
          <span>📋</span> Copy
        </>
      )}
    </button>
  );
}

export default function GetStarted() {
  const location = useLocation();

  // Read ?fw= query param to pre-select framework from navbar search
  const getFwFromSearch = (search) => {
    try {
      const params = new URLSearchParams(search);
      return params.get('fw') || null;
    } catch {
      return null;
    }
  };

  const [selectedId, setSelectedId] = useState(() => {
    // Initialize from URL immediately to prevent first-render flash
    try {
      const params = new URLSearchParams(location.search);
      const fwId = params.get('fw');
      if (fwId) {
        const fw = frameworks.find(f => f.id === fwId);
        if (fw && !fw.isPremium) return fwId;
      }
    } catch {}
    return 'cis';
  });
  const [highlightedId, setHighlightedId] = useState(() => {
    try {
      const params = new URLSearchParams(location.search);
      const fwId = params.get('fw');
      if (fwId) {
        const fw = frameworks.find(f => f.id === fwId);
        if (fw && fw.isPremium) return fwId;
      }
    } catch {}
    return null;
  });
  const [pulsingId, setPulsingId] = useState(null);
  const [step, setStep] = useState(1); // 1 = select, 2 = commands
  const [showManual, setShowManual] = useState(false);
  const gridRef = useRef(null);
  const continueBtnRef = useRef(null);

  const selectedFramework = frameworks.find(f => f.id === selectedId);
  const baseUrl = useBaseUrl('/');

  // Reactively handle URL ?fw= param — runs on mount AND whenever the URL changes
  // (covers both: arriving from another page and searching while already on this page)
  useEffect(() => {
    const fwId = getFwFromSearch(location.search);
    if (!fwId) return;

    const fw = frameworks.find(f => f.id === fwId);
    if (!fw) return;

    if (!fw.isPremium) {
      setSelectedId(fwId);
      setHighlightedId(null);
    } else {
      setHighlightedId(fwId);
    }

    // Use React state for pulse — avoids DOM class conflicts with box-shadow
    const timer = setTimeout(() => {
      const card = document.querySelector(`[data-fw="${fwId}"]`);
      if (card) {
        card.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }
      setPulsingId(fwId);
      setTimeout(() => setPulsingId(null), 900);
    }, 150);

    return () => clearTimeout(timer);
  }, [location.search]); // ← re-runs every time the query string changes

  const handleDownloadCmd = (fw) => {
    if (!fw) return;

    const cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl : `${baseUrl}/`;
    const downloadUrl = `${cleanBaseUrl}download/run-m365advisor-${fw.id}.cmd`;

    const link = document.createElement('a');
    link.href = downloadUrl;
    link.download = `run-m365advisor-${fw.id}.cmd`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handleMagicDownload = () => {
    const cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl : `${baseUrl}/`;
    const downloadUrl = `${cleanBaseUrl}download/run-m365advisor-m365.cmd`;

    const link = document.createElement('a');
    link.href = downloadUrl;
    link.download = `run-m365advisor-all-compliance.cmd`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handleContinue = () => {
    setStep(2);
  };

  return (
    <Layout
      title="Get Started Wizard"
      description="Select your Microsoft 365 compliance framework and get running commands instantly."
    >
      <div className={styles.getStartedPage}>
        <div className={styles.gridBackground} />
        <div className={styles.heroGlow} />

        <div className="container">
          <div className={styles.wizardHeader}>
            <h1 className={styles.wizardTitle}>Setup Wizard</h1>
            <p className={styles.wizardDesc}>
              Configure and run M365 Advisor security audits tailored to your company's compliance benchmarks in a couple of steps.
            </p>
          </div>

          {/* Steps Breadcrumb */}
          <div className={styles.stepsIndicator}>
            <div className={clsx(styles.stepNode, step >= 1 && styles.stepNodeActive)}>
              <div className={styles.stepNumber}>1</div>
              <span>Select Framework</span>
            </div>
            <div className={clsx(styles.stepLine, step >= 2 && styles.stepLineActive)} />
            <div className={clsx(styles.stepNode, step >= 2 && styles.stepNodeActive)}>
              <div className={styles.stepNumber}>2</div>
              <span>Run Commands</span>
            </div>
          </div>

          {step === 1 ? (
            <>
              {/* Step 1 Content */}
              <div className={styles.frameworkGrid} ref={gridRef}>
                {frameworks.map((fw) => (
                  <div
                    key={fw.id}
                    data-fw={fw.id}
                    className={clsx(
                      styles.frameworkCard,
                      fw.isPremium && styles.frameworkCardPremium,
                      !fw.isPremium && selectedId === fw.id && styles.frameworkCardSelected,
                      fw.isPremium && highlightedId === fw.id && styles.frameworkCardHighlighted,
                      pulsingId === fw.id && styles.fwCardPulse
                    )}
                    style={{
                      '--card-accent': fw.accent,
                      '--card-glow': fw.glow
                    }}
                    onClick={() => {
                      if (fw.isPremium) {
                        const subject = encodeURIComponent(`Access Request: Premium Module - ${fw.title}`);
                        const body = encodeURIComponent(
                          `Hi Salman,\n\nI want to access this premium ${fw.title} auditing module. Please provide me with the details on how to get started.\n\nThanks!`
                        );
                        window.location.href = `mailto:Salman.Sayyed@onmeridian.com?subject=${subject}&body=${body}`;
                      } else {
                        setSelectedId(fw.id);
                        setTimeout(() => {
                          continueBtnRef.current?.scrollIntoView({ behavior: 'smooth', block: 'center' });
                        }, 50);
                      }
                    }}
                  >
                    <div>
                      <div className={styles.cardHeader}>
                        <div className={styles.cardIcon}>{fw.icon}</div>
                        {fw.isPremium ? (
                          <span className={styles.premiumBadge}>🔒 PREMIUM</span>
                        ) : (
                          <div className={styles.cardRadio}>
                            <div className={styles.cardRadioDot} />
                          </div>
                        )}
                      </div>
                      <h3 className={styles.cardTitle}>{fw.title}</h3>
                      <p className={styles.cardSubtitle}>{fw.subtitle}</p>
                      <p className={styles.cardDesc}>{fw.desc}</p>
                    </div>
                    <span className={styles.cardTag}>{fw.tag}</span>
                  </div>
                ))}
              </div>

              <div className={styles.actionsRow}>
                <button
                  ref={continueBtnRef}
                  className={styles.btnPrimary}
                  disabled={!selectedId}
                  onClick={handleContinue}
                  type="button"
                >
                  Continue to Commands →
                </button>

                <button
                  className={styles.btnMagic}
                  onClick={handleMagicDownload}
                  type="button"
                  title="Download all-compliance check agent script"
                >
                  <span className={styles.magicSparkle}>✨</span>
                  <span>All-Compliance Agent</span>
                  <span className={styles.magicBadge}>DOWNLOAD</span>
                </button>
              </div>
            </>
          ) : (
            <>
              {/* Step 2 Content */}
              <div className={styles.commandsContainer}>

                <div
                  className={styles.selectedBadge}
                  style={{
                    '--card-accent': selectedFramework.accent,
                    '--card-glow': selectedFramework.glow
                  }}
                >
                  <span className={styles.selectedIcon}>{selectedFramework.icon}</span>
                  <span>Targeting: <span className={styles.selectedText}>{selectedFramework.title}</span></span>
                </div>

                {/* Automated Launcher Card */}
                <div className={styles.launcherCard} style={{
                  '--card-accent': selectedFramework.accent,
                  '--card-glow': selectedFramework.glow
                }}>
                  <div className={styles.launcherHeader}>
                    <div className={styles.launcherIconWrapper}>
                      <div className={styles.launcherIconPulse} />
                      <span className={styles.launcherIcon}>🚀</span>
                    </div>
                    <div className={styles.launcherTitleSection}>
                      <h3 className={styles.launcherCardTitle}>One-Click Automated Assessment</h3>
                      <p className={styles.launcherCardStatus}>📥 Launcher script is ready!</p>
                    </div>
                  </div>
                  
                  <p className={styles.launcherCardDesc}>
                    A customized Windows runner script (<strong>run-m365advisor-{selectedFramework.id}.cmd</strong>) has been generated and downloaded to your computer.
                    Opening it will automatically launch PowerShell, install dependencies, establish connection, and execute the audit.
                  </p>

                  <div className={styles.launcherActions}>
                    <button
                      className={styles.btnLaunch}
                      onClick={() => handleDownloadCmd(selectedFramework)}
                      type="button"
                    >
                      📥 Download Launcher Script
                    </button>
                  </div>

                  <div className={styles.launcherGuide}>
                    <h4 className={styles.guideTitle}>How to run:</h4>
                    <ol className={styles.guideList}>
                      <li>Open your <strong>Downloads</strong> folder (or browser downloads list).</li>
                      <li>Double-click the downloaded <code>run-m365advisor-{selectedFramework.id}.cmd</code> file.</li>
                      <li>PowerShell will open and configure automatically. Sign in when prompted!</li>
                    </ol>
                  </div>
                </div>

                {/* Collapsible Manual Setup */}
                <div className={styles.manualAccordion}>
                  <button
                    className={clsx(styles.manualAccordionHeader, showManual && styles.manualAccordionHeaderOpen)}
                    onClick={() => setShowManual(!showManual)}
                    type="button"
                  >
                    <span>{showManual ? '▼' : '▶'}</span>
                    <span>Alternative: Manual Execution (Copy &amp; Paste)</span>
                  </button>

                  {showManual && (
                    <div className={styles.manualAccordionBody}>
                      {/* Step 2.1: Install */}
                      <div className={styles.commandStep}>
                        <div className={styles.commandStepHeader}>
                          <div className={styles.commandStepTitle}>
                            <span className={styles.commandStepNum}>1</span>
                            Install PowerShell Module
                          </div>
                          <CopyButton text={selectedFramework.setupCmd} />
                        </div>
                        <p className={styles.commandStepDesc}>
                          Run this command in administrative PowerShell to install the Audit365 module, Pester utility, and default tests directory.
                        </p>
                        <div className={styles.terminalWrapper}>
                          <div className={styles.terminalHeader}>
                            <div className={styles.terminalDots}>
                              <div className={styles.terminalDot} />
                              <div className={styles.terminalDot} />
                              <div className={styles.terminalDot} />
                            </div>
                            <div className={styles.terminalTitle}>PowerShell</div>
                          </div>
                          <pre className={styles.terminalBody}>{selectedFramework.setupCmd}</pre>
                        </div>
                      </div>

                      {/* Step 2.2: Connect */}
                      <div className={styles.commandStep}>
                        <div className={styles.commandStepHeader}>
                          <div className={styles.commandStepTitle}>
                            <span className={styles.commandStepNum}>2</span>
                            Establish M365 Connection
                          </div>
                          <CopyButton text={selectedFramework.connectCmd} />
                        </div>
                        <p className={styles.commandStepDesc}>
                          Authenticate to your Microsoft 365 tenant. A web login window will prompt you to approve access to Microsoft Graph API.
                        </p>
                        <div className={styles.terminalWrapper}>
                          <div className={styles.terminalHeader}>
                            <div className={styles.terminalDots}>
                              <div className={styles.terminalDot} />
                              <div className={styles.terminalDot} />
                              <div className={styles.terminalDot} />
                            </div>
                            <div className={styles.terminalTitle}>PowerShell</div>
                          </div>
                          <pre className={styles.terminalBody}>{selectedFramework.connectCmd}</pre>
                        </div>
                      </div>

                      {/* Step 2.3: Run */}
                      <div className={styles.commandStep}>
                        <div className={styles.commandStepHeader}>
                          <div className={styles.commandStepTitle}>
                            <span className={styles.commandStepNum}>3</span>
                            Run Framework Assessment
                          </div>
                          <CopyButton text={selectedFramework.runCmd} />
                        </div>
                        <p className={styles.commandStepDesc}>
                          Initiate the automated compliance check. When complete, test results are automatically rendered as an HTML dashboard under your local output folder.
                        </p>
                        <div className={styles.terminalWrapper}>
                          <div className={styles.terminalHeader}>
                            <div className={styles.terminalDots}>
                              <div className={styles.terminalDot} />
                              <div className={styles.terminalDot} />
                              <div className={styles.terminalDot} />
                            </div>
                            <div className={styles.terminalTitle}>PowerShell</div>
                          </div>
                          <pre className={styles.terminalBody}>{selectedFramework.runCmd}</pre>
                        </div>
                      </div>
                    </div>
                  )}
                </div>

              </div>

              <div className={styles.actionsRow}>
                <button
                  className={styles.btnSecondary}
                  onClick={() => setStep(1)}
                  type="button"
                >
                  ← Back to Frameworks
                </button>
              </div>
            </>
          )}

        </div>
      </div>
    </Layout>
  );
}
