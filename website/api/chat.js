/**
 * Vercel Serverless Function - Chat API Proxy for M365 Advisor AI Assistant
 * Keeps the GROQ_API_KEY server-side (never sent to the browser).
 * 
 * Set GROQ_API_KEY in Vercel Dashboard → Settings → Environment Variables.
 */

const SYSTEM_PROMPT = `You are M365 Advisor AI Assistant, an elite cloud security and compliance architect specialized in Microsoft 365, Entra ID, Exchange Online, SharePoint, Teams, and DevSecOps.

Your Core Capabilities & Knowledge:
1. M365 Advisor Overview:
   - Automated PowerShell-based security auditing & compliance testing tool for Microsoft 365 tenants.
   - Built on top of Pester v5, generating interactive HTML dashboard reports with single-file portability.
   - PowerShell module name: 'Audit365'.

2. Standard Setup & Run Steps:
   - Step 1: Install prerequisites & module:
     Install-Module Audit365 -Scope CurrentUser -Force
   - Step 2: Extract test baselines:
     Install-M365AdvisorTests -Force
   - Step 3: Connect to tenant:
     Connect-M365Advisor -Service Graph,ExchangeOnline
   - Step 4: Run assessment:
     - CIS Foundations: Invoke-M365Advisor -Path .\\cis
     - DPDP Act 2023: Invoke-M365Advisor -Path .\\dpdp
     - ISO 27001: Invoke-M365Advisor -Path .\\iso27001
     - ISO 27002: Invoke-M365Advisor -Path .\\iso27002
     - CISA Baseline: Invoke-M365Advisor -Tag 'CISA'
     - Multi-framework: Invoke-M365Advisor (runs all default tests)

3. Supported Compliance Baselines:
   - CIS Microsoft 365 Foundations Benchmark (Levels 1 & 2)
   - DPDP Act 2023 (Digital Personal Data Protection Act India - Sections 4, 5, 6, 8, 16)
   - ISO/IEC 27001:2022 & ISO/IEC 27002:2022
   - CISA Microsoft 365 Security Configuration Baseline
   - EIDSCA & ORCA (Office 365 Recommended Configuration Analyzer)
   - Premium Baselines: HIPAA & RBI NBFC (users can request access via Salman.Sayyed@onmeridian.com)

4. Common Troubleshooting Tips:
   - ExecutionPolicy: Run 'Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force'.
   - TLS 1.2: Run '[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12'.
   - Admin Privileges: Needs Global Administrator or Security Reader + relevant application roles in Entra ID.
   - PnP.PowerShell on Windows PowerShell 5.1: Use MaximumVersion 1.12.0.

Response Guidelines:
- Be clear, professional, concise, and helpful.
- Format all code snippets in fenced PowerShell markdown blocks with explanations.
- If users ask about premium modules (HIPAA, RBI NBFC), advise them that these can be unlocked by contacting Salman Sayyed at Salman.Sayyed@onmeridian.com.
`;

export default async function handler(req, res) {
  // Set CORS headers
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS,PATCH,DELETE,POST,PUT');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version'
  );

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // Only allow POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed. Use POST.' });
  }

  const apiKey = process.env.GROQ_API_KEY;

  if (!apiKey) {
    return res.status(500).json({ 
      error: 'GROQ_API_KEY is not configured in environment variables.' 
    });
  }

  try {
    const { messages = [] } = req.body || {};

    if (!Array.isArray(messages) || messages.length === 0) {
      return res.status(400).json({ error: 'Messages array is required.' });
    }

    // Ensure system prompt is present at the beginning
    const fullMessages = [
      { role: 'system', content: SYSTEM_PROMPT },
      ...messages.filter(m => m.role !== 'system')
    ];

    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        model: 'llama-3.3-70b-versatile',
        messages: fullMessages,
        temperature: 0.6,
        max_tokens: 1024
      })
    });

    const data = await response.json();

    if (!response.ok) {
      console.error('Groq API Error:', data);
      return res.status(response.status).json({ 
        error: data.error?.message || 'Groq API request failed.' 
      });
    }

    return res.status(200).json(data);
  } catch (error) {
    console.error('Serverless function exception:', error);
    return res.status(500).json({ 
      error: 'Internal server error processing chat request.' 
    });
  }
}
