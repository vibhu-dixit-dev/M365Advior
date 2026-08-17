import React, { useState, useEffect, useRef } from 'react';
import clsx from 'clsx';
import styles from './styles.module.css';

const INITIAL_MESSAGE = {
  id: 'init-msg',
  role: 'assistant',
  content: `👋 **Hello! I am your M365 Advisor AI Assistant.**\n\nHow can I help you audit your Microsoft 365 tenant, verify compliance baselines (CIS, DPDP, ISO 27001), or execute PowerShell checks today?`
};

const QUICK_PROMPTS = [
  "🚀 How to run CIS Benchmark assessment?",
  "⚖️ What checks are in DPDP Act 2023?",
  "🛠️ How to fix PowerShell execution errors?",
  "🔒 How to request HIPAA & RBI NBFC modules?",
  "📊 Where is the HTML report generated?"
];

function CodeSnippet({ code, lang = 'powershell' }) {
  const [copied, setCopied] = useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className={styles.codeBox}>
      <div className={styles.codeHeader}>
        <span>{lang}</span>
        <button type="button" className={styles.copyCodeBtn} onClick={handleCopy}>
          {copied ? '✓ Copied' : '📋 Copy'}
        </button>
      </div>
      <pre className={styles.codeBody}><code>{code}</code></pre>
    </div>
  );
}

function FormattedContent({ text }) {
  if (!text) return null;

  // Split by fenced code blocks
  const parts = text.split(/(```[\s\S]*?```)/g);

  return (
    <div>
      {parts.map((part, index) => {
        if (part.startsWith('```') && part.endsWith('```')) {
          const lines = part.slice(3, -3).trim().split('\n');
          const firstLine = lines[0].trim();
          let lang = 'powershell';
          let codeLines = lines;
          if (firstLine && !firstLine.includes(' ') && firstLine.length < 15) {
            lang = firstLine;
            codeLines = lines.slice(1);
          }
          return <CodeSnippet key={index} code={codeLines.join('\n')} lang={lang} />;
        }

        // Parse basic markdown lines (bullets, bold, inline code)
        const paragraphs = part.split('\n\n');
        return paragraphs.map((para, pIdx) => {
          if (!para.trim()) return null;

          const lines = para.split('\n');
          const isBulletList = lines.every(l => l.trim().startsWith('- ') || l.trim().startsWith('* '));

          if (isBulletList) {
            return (
              <ul key={`${index}-${pIdx}`}>
                {lines.map((l, lIdx) => {
                  const content = l.replace(/^[-*]\s+/, '');
                  return <li key={lIdx} dangerouslySetInnerHTML={{ __html: renderInlineMarkdown(content) }} />;
                })}
              </ul>
            );
          }

          return (
            <p key={`${index}-${pIdx}`} style={{ margin: '0 0 0.5rem' }} dangerouslySetInnerHTML={{ __html: renderInlineMarkdown(para) }} />
          );
        });
      })}
    </div>
  );
}

function renderInlineMarkdown(text) {
  if (!text) return '';
  return text
    // Replace **bold**
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    // Replace *italic*
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    // Replace `code`
    .replace(/`([^`]+)`/g, '<code>$1</code>')
    // Convert newlines to breaks if inside paragraph
    .replace(/\n/g, '<br/>');
}

// Local mock responder when testing locally without a live Groq API key
function getLocalFallbackResponse(query) {
  const q = query.toLowerCase();
  if (q.includes('cis')) {
    return `### Running CIS Benchmark Assessment\n\nYou can execute the automated CIS foundations assessment by running:\n\n\`\`\`powershell\nSet-Location (Join-Path $HOME 'M365Advisor-tests')\nConnect-M365Advisor -Service Graph,ExchangeOnline\nInvoke-M365Advisor -Path .\\cis\n\`\`\`\n\nThis tests your tenant against 44+ automated CIS controls covering identity, permissions, and threat policies.`;
  }
  if (q.includes('dpdp')) {
    return `### DPDP Act 2023 Compliance\n\nM365 Advisor includes **45+ automated compliance checks** mapped directly to the Indian Digital Personal Data Protection Act, 2023:\n\n- **Section 4 & 5:** Consent workflows and explicit notice verification.\n- **Section 6:** Revocation and self-service privacy portals.\n- **Section 8:** Breach readiness, unified audit log, and retention policies.\n\nRun DPDP audit with:\n\n\`\`\`powershell\nInvoke-M365Advisor -Path .\\dpdp\n\`\`\``;
  }
  if (q.includes('error') || q.includes('fix') || q.includes('powershell')) {
    return `### Troubleshooting PowerShell Audit Errors\n\n1. **Execution Policy Restriction:**\n\`\`\`powershell\nSet-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force\n\`\`\`\n2. **Enable TLS 1.2 Security Protocol:**\n\`\`\`powershell\n[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12\n\`\`\`\n3. **Re-install fresh modules:**\n\`\`\`powershell\nInstall-Module Audit365 -Scope CurrentUser -Force\nInstall-M365AdvisorTests -Force\n\`\`\``;
  }
  if (q.includes('hipaa') || q.includes('hippa') || q.includes('rbi') || q.includes('premium')) {
    return `### Requesting Premium Compliance Baselines\n\n**HIPAA** (Healthcare Security) and **RBI NBFC** (Financial Governance) are enterprise premium baselines.\n\nTo request access, contact **Salman Sayyed** at:\n📧 **Salman.Sayyed@onmeridian.com**\n\nOr click the **🔒 PREMIUM** cards on the website to trigger the pre-filled mailbox request!`;
  }
  if (q.includes('report') || q.includes('html')) {
    return `### Viewing Your Audit Results\n\nAfter running \`Invoke-M365Advisor\`, an interactive, single-file HTML report is generated at:\n\n\`\`\`\n$HOME\\M365Advisor-tests\\test-results\\TestResults.html\n\`\`\`\n\nYou can open this file in any web browser to view severity distributions, category bars, and remediation guides.`;
  }

  return `I can help you with all aspects of **M365 Advisor**!\n\n- **Setup:** \`Install-Module Audit365 -Scope CurrentUser -Force\`\n- **Baselines:** \`Invoke-M365Advisor -Path .\\cis\` or \`Invoke-M365Advisor -Path .\\dpdp\`\n- **Reports:** Interactive HTML reports generated in \`test-results\\\`.\n\nWhat specific compliance rule or cmdlet would you like guidance on?`;
}

export default function Chatbot() {
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState(() => {
    try {
      const saved = sessionStorage.getItem('m365advisor_chat_history');
      if (saved) return JSON.parse(saved);
    } catch {}
    return [INITIAL_MESSAGE];
  });
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [hasUnread, setHasUnread] = useState(true);

  const messagesEndRef = useRef(null);
  const inputRef = useRef(null);

  useEffect(() => {
    try {
      sessionStorage.setItem('m365advisor_chat_history', JSON.stringify(messages));
    } catch {}
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, isLoading]);

  useEffect(() => {
    if (isOpen) {
      setHasUnread(false);
      setTimeout(() => inputRef.current?.focus(), 150);
    }
  }, [isOpen]);

  const handleSendMessage = async (textToSend) => {
    const query = (textToSend || input).trim();
    if (!query || isLoading) return;

    const userMsg = {
      id: `user-${Date.now()}`,
      role: 'user',
      content: query
    };

    const updatedMessages = [...messages, userMsg];
    setMessages(updatedMessages);
    setInput('');
    setIsLoading(true);

    try {
      // Format messages payload for Groq API
      const apiPayload = updatedMessages
        .filter(m => m.id !== 'init-msg')
        .map(m => ({ role: m.role, content: m.content }));

      const res = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ messages: apiPayload })
      });

      if (res.ok) {
        const data = await res.json();
        const botReply = data.choices?.[0]?.message?.content || 'No response received from assistant.';
        setMessages(prev => [
          ...prev,
          { id: `bot-${Date.now()}`, role: 'assistant', content: botReply }
        ]);
      } else {
        // Use local fallback if serverless API is offline or unconfigured locally
        const fallbackText = getLocalFallbackResponse(query);
        setMessages(prev => [
          ...prev,
          { id: `bot-${Date.now()}`, role: 'assistant', content: fallbackText }
        ]);
      }
    } catch (err) {
      // Network failure / local offline fallback
      const fallbackText = getLocalFallbackResponse(query);
      setMessages(prev => [
        ...prev,
        { id: `bot-${Date.now()}`, role: 'assistant', content: fallbackText }
      ]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  const handleClearChat = () => {
    setMessages([INITIAL_MESSAGE]);
    try {
      sessionStorage.removeItem('m365advisor_chat_history');
    } catch {}
  };

  return (
    <div className={styles.chatbotContainer}>
      {/* Floating Action Button */}
      <button
        type="button"
        className={styles.triggerBtn}
        onClick={() => setIsOpen(prev => !prev)}
        aria-label={isOpen ? 'Close AI Chat' : 'Open AI Chat'}
      >
        <span className={styles.triggerIcon}>
          {isOpen ? '✕' : '💬'}
        </span>
        {!isOpen && hasUnread && (
          <span className={styles.triggerBadge}>AI</span>
        )}
      </button>

      {/* Expandable Chat Modal Window */}
      {isOpen && (
        <div className={styles.chatWindow}>
          {/* Header */}
          <div className={styles.chatHeader}>
            <div className={styles.headerLeft}>
              <div className={styles.botAvatar}>🤖</div>
              <div className={styles.botInfo}>
                <span className={styles.botName}>M365 Advisor AI</span>
                <span className={styles.botStatus}>
                  <span className={styles.statusDot} />
                  Online • Llama 3.3
                </span>
              </div>
            </div>
            <div className={styles.headerActions}>
              <button
                type="button"
                className={styles.iconBtn}
                onClick={handleClearChat}
                title="Clear Conversation"
              >
                🗑️
              </button>
              <button
                type="button"
                className={styles.iconBtn}
                onClick={() => setIsOpen(false)}
                title="Minimize"
              >
                ✕
              </button>
            </div>
          </div>

          {/* Chat Messages Body */}
          <div className={styles.chatBody}>
            {messages.map((msg) => (
              <div
                key={msg.id}
                className={clsx(
                  styles.messageRow,
                  msg.role === 'user' ? styles.messageRowUser : styles.messageRowBot
                )}
              >
                <div
                  className={clsx(
                    styles.msgAvatar,
                    msg.role === 'user' ? styles.msgAvatarUser : styles.msgAvatarBot
                  )}
                >
                  {msg.role === 'user' ? '👤' : '🛡️'}
                </div>
                <div
                  className={clsx(
                    styles.messageBubble,
                    msg.role === 'user' ? styles.bubbleUser : styles.bubbleBot
                  )}
                >
                  <FormattedContent text={msg.content} />
                </div>
              </div>
            ))}

            {isLoading && (
              <div className={clsx(styles.messageRow, styles.messageRowBot)}>
                <div className={clsx(styles.msgAvatar, styles.msgAvatarBot)}>🛡️</div>
                <div className={clsx(styles.messageBubble, styles.bubbleBot)}>
                  <div className={styles.typingIndicator}>
                    <div className={styles.typingDot} />
                    <div className={styles.typingDot} />
                    <div className={styles.typingDot} />
                  </div>
                </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          {/* Quick Starter Chips */}
          <div className={styles.quickChipsWrapper}>
            {QUICK_PROMPTS.map((prompt, idx) => (
              <button
                key={idx}
                type="button"
                className={styles.chip}
                onClick={() => handleSendMessage(prompt)}
              >
                {prompt}
              </button>
            ))}
          </div>

          {/* Input Bar */}
          <div className={styles.chatInputArea}>
            <input
              ref={inputRef}
              type="text"
              className={styles.chatInput}
              placeholder="Ask anything about M365 auditing..."
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
              disabled={isLoading}
            />
            <button
              type="button"
              className={styles.sendBtn}
              onClick={() => handleSendMessage()}
              disabled={!input.trim() || isLoading}
              aria-label="Send message"
            >
              ➤
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
