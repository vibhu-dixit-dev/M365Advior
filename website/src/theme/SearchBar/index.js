import React, { useState, useRef, useEffect } from 'react';
import { useHistory } from '@docusaurus/router';

const COMPLIANCE_FRAMEWORKS = [
  {
    id: 'cis',
    title: 'CIS Benchmarks',
    icon: '🌀',
    keywords: ['cis', 'benchmark', 'foundations', 'microsoft 365', 'cis benchmark'],
  },
  {
    id: 'iso27001',
    title: 'ISO/IEC 27001:2022',
    icon: '🌐',
    keywords: ['iso', 'iso27001', 'iso 27001', 'isms', 'information security', '27001'],
  },
  {
    id: 'iso27002',
    title: 'ISO/IEC 27002:2022',
    icon: '📋',
    keywords: ['iso', 'iso27002', 'iso 27002', 'security controls', '27002'],
  },
  {
    id: 'cisa',
    title: 'CISA SCuBA Baselines',
    icon: '🦅',
    keywords: ['cisa', 'scuba', 'cisa scuba', 'federal', 'cloud security'],
  },
  {
    id: 'eidsca',
    title: 'Entra ID SCA',
    icon: '🛡️',
    keywords: ['eidsca', 'eidsa', 'entra id', 'entra', 'identity', 'sca'],
  },
  {
    id: 'mt',
    title: 'M365 Advisor Baselines (MT)',
    icon: '🔥',
    keywords: ['mt', 'm365', 'microsoft tenant', 'tenant security', 'baselines', 'posture'],
  },
  {
    id: 'dpdp',
    title: 'DPDP Act 2023',
    icon: '⚖️',
    keywords: ['dpdp', 'dpdpa', 'digital personal data', 'data protection', 'privacy act', 'india'],
  },
  {
    id: 'hippa',
    title: 'HIPPA',
    icon: '🩺',
    keywords: ['hippa', 'hipaa', 'healthcare', 'privacy', 'health'],
    isPremium: true,
  },
  {
    id: 'rbi-nbfc',
    title: 'RBI NBFC',
    icon: '🏦',
    keywords: ['rbi', 'nbfc', 'reserve bank', 'india', 'financial'],
    isPremium: true,
  },
];

export default function SearchBar() {
  const [query, setQuery] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const [showNotFound, setShowNotFound] = useState(false);
  const inputRef = useRef(null);
  const wrapRef = useRef(null);
  const history = useHistory();

  const normalizedQuery = query.trim().toLowerCase();

  const filtered = normalizedQuery
    ? COMPLIANCE_FRAMEWORKS.filter((fw) => {
        const inTitle = fw.title.toLowerCase().includes(normalizedQuery);
        const inKeywords = fw.keywords.some((kw) => kw.includes(normalizedQuery));
        return inTitle || inKeywords;
      })
    : [];

  // Close dropdown on outside click
  useEffect(() => {
    const handleClick = (e) => {
      if (wrapRef.current && !wrapRef.current.contains(e.target)) {
        setIsOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClick);
    return () => document.removeEventListener('mousedown', handleClick);
  }, []);

  const handleChange = (e) => {
    const val = e.target.value;
    setQuery(val);
    setIsOpen(val.trim().length > 0);
    setShowNotFound(false);
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && normalizedQuery) {
      if (filtered.length > 0) {
        navigateTo(filtered[0]);
      } else {
        setIsOpen(false);
        setShowNotFound(true);
      }
    }
    if (e.key === 'Escape') {
      setIsOpen(false);
      setQuery('');
    }
  };

  const navigateTo = (fw) => {
    setQuery('');
    setIsOpen(false);
    history.push(`/get-started?fw=${fw.id}`);
  };

  const clearSearch = () => {
    setQuery('');
    setIsOpen(false);
    setShowNotFound(false);
    inputRef.current?.focus();
  };

  return (
    <>
      {/* ── Search Widget ── */}
      <div ref={wrapRef} style={{ position: 'relative' }}>
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            background: 'rgba(255,255,255,0.07)',
            border: isOpen
              ? '1px solid rgba(0,242,254,0.45)'
              : '1px solid rgba(255,255,255,0.13)',
            borderRadius: '8px',
            padding: '0.38rem 0.8rem',
            gap: '0.5rem',
            minWidth: '200px',
            transition: 'border-color 0.2s, box-shadow 0.2s',
            boxShadow: isOpen ? '0 0 0 2px rgba(0,242,254,0.1)' : 'none',
          }}
        >
          {/* Search icon */}
          <svg
            width="14"
            height="14"
            viewBox="0 0 20 20"
            fill="none"
            style={{ flexShrink: 0, opacity: 0.55 }}
          >
            <circle cx="8.5" cy="8.5" r="5.5" stroke="currentColor" strokeWidth="1.8" />
            <path d="M13.5 13.5L17 17" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" />
          </svg>

          <input
            ref={inputRef}
            type="text"
            value={query}
            onChange={handleChange}
            onKeyDown={handleKeyDown}
            onFocus={() => { if (query.trim()) setIsOpen(true); }}
            placeholder="Search…"
            aria-label="Search compliance frameworks"
            style={{
              background: 'transparent',
              border: 'none',
              outline: 'none',
              color: 'var(--ifm-color-content, #fff)',
              fontSize: '0.88rem',
              width: '130px',
              fontFamily: 'inherit',
            }}
          />

          {/* Keyboard hint when empty */}
          {!query && (
            <span
              style={{
                display: 'flex',
                gap: '2px',
                flexShrink: 0,
                opacity: 0.4,
              }}
            >
              <kbd
                style={{
                  fontSize: '0.65rem',
                  background: 'rgba(255,255,255,0.1)',
                  border: '1px solid rgba(255,255,255,0.15)',
                  borderRadius: '3px',
                  padding: '1px 4px',
                  fontFamily: 'inherit',
                  color: 'inherit',
                }}
              >
                ctrl
              </kbd>
              <kbd
                style={{
                  fontSize: '0.65rem',
                  background: 'rgba(255,255,255,0.1)',
                  border: '1px solid rgba(255,255,255,0.15)',
                  borderRadius: '3px',
                  padding: '1px 4px',
                  fontFamily: 'inherit',
                  color: 'inherit',
                }}
              >
                K
              </kbd>
            </span>
          )}

          {/* Clear button */}
          {query && (
            <button
              onClick={clearSearch}
              aria-label="Clear search"
              type="button"
              style={{
                background: 'none',
                border: 'none',
                color: 'rgba(255,255,255,0.45)',
                cursor: 'pointer',
                padding: 0,
                fontSize: '0.8rem',
                lineHeight: 1,
                flexShrink: 0,
              }}
            >
              ✕
            </button>
          )}
        </div>

        {/* ── Dropdown ── */}
        {isOpen && query.trim() && (
          <div
            style={{
              position: 'absolute',
              top: 'calc(100% + 8px)',
              right: 0,
              minWidth: '280px',
              background: 'linear-gradient(135deg,#0d1117,#10161f)',
              border: '1px solid rgba(255,255,255,0.1)',
              borderRadius: '12px',
              overflow: 'hidden',
              zIndex: 9990,
              boxShadow: '0 20px 50px rgba(0,0,0,0.6), 0 0 0 1px rgba(255,255,255,0.04)',
            }}
          >
            {filtered.length > 0 ? (
              <>
                <div
                  style={{
                    padding: '0.55rem 1rem 0.35rem',
                    fontSize: '0.72rem',
                    color: 'rgba(255,255,255,0.35)',
                    letterSpacing: '0.06em',
                    textTransform: 'uppercase',
                    borderBottom: '1px solid rgba(255,255,255,0.05)',
                  }}
                >
                  Compliance Frameworks
                </div>
                {filtered.map((fw, i) => (
                  <button
                    key={fw.id}
                    onClick={() => navigateTo(fw)}
                    type="button"
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      gap: '0.75rem',
                      padding: '0.7rem 1rem',
                      background: 'none',
                      border: 'none',
                      borderBottom:
                        i < filtered.length - 1
                          ? '1px solid rgba(255,255,255,0.05)'
                          : 'none',
                      color: '#fff',
                      cursor: 'pointer',
                      width: '100%',
                      textAlign: 'left',
                      transition: 'background 0.12s',
                    }}
                    onMouseEnter={(e) =>
                      (e.currentTarget.style.background = 'rgba(0,242,254,0.06)')
                    }
                    onMouseLeave={(e) =>
                      (e.currentTarget.style.background = 'none')
                    }
                  >
                    <span style={{ fontSize: '1.15rem' }}>{fw.icon}</span>
                    <span style={{ fontSize: '0.88rem', flex: 1 }}>{fw.title}</span>
                    {fw.isPremium && (
                      <span
                        style={{
                          fontSize: '0.65rem',
                          color: '#fb923c',
                          background: 'rgba(251,146,60,0.1)',
                          border: '1px solid rgba(251,146,60,0.25)',
                          borderRadius: '4px',
                          padding: '1px 6px',
                          fontWeight: 600,
                          letterSpacing: '0.04em',
                        }}
                      >
                        PREMIUM
                      </span>
                    )}
                    <span style={{ fontSize: '0.8rem', opacity: 0.35 }}>→</span>
                  </button>
                ))}
              </>
            ) : (
              <div
                style={{
                  padding: '1.25rem 1rem',
                  textAlign: 'center',
                  color: 'rgba(255,255,255,0.45)',
                  fontSize: '0.85rem',
                  lineHeight: 1.5,
                }}
              >
                <div style={{ fontSize: '1.4rem', marginBottom: '0.5rem' }}>🔍</div>
                <div>
                  No results for{' '}
                  <strong style={{ color: '#00f2fe' }}>"{query}"</strong>
                </div>
                <button
                  onClick={() => { setIsOpen(false); setShowNotFound(true); }}
                  type="button"
                  style={{
                    marginTop: '0.65rem',
                    background: 'rgba(0,242,254,0.08)',
                    border: '1px solid rgba(0,242,254,0.2)',
                    color: '#00f2fe',
                    padding: '0.3rem 0.9rem',
                    borderRadius: '6px',
                    cursor: 'pointer',
                    fontSize: '0.78rem',
                    fontFamily: 'inherit',
                  }}
                >
                  See details
                </button>
              </div>
            )}
          </div>
        )}
      </div>

      {/* ── Not Available Modal ── */}
      {showNotFound && (
        <>
          {/* Backdrop */}
          <div
            onClick={() => setShowNotFound(false)}
            style={{
              position: 'fixed',
              inset: 0,
              background: 'rgba(5,6,8,0.72)',
              backdropFilter: 'blur(6px)',
              zIndex: 9998,
              animation: 'sbBackdropIn 0.2s ease both',
            }}
          />
          {/* Dialog */}
          <div
            role="dialog"
            aria-modal="true"
            aria-labelledby="sb-not-found-title"
            style={{
              position: 'fixed',
              top: '50%',
              left: '50%',
              transform: 'translate(-50%,-50%)',
              zIndex: 9999,
              width: 'min(480px, calc(100vw - 2rem))',
              background: 'linear-gradient(135deg,#0d1117 0%,#10161f 100%)',
              border: '1px solid rgba(255,255,255,0.1)',
              borderRadius: '20px',
              padding: '2.5rem 2rem 2rem',
              textAlign: 'center',
              overflow: 'hidden',
              boxShadow:
                '0 0 0 1px rgba(255,255,255,0.05), 0 40px 80px -20px rgba(0,0,0,0.85), 0 0 60px rgba(0,242,254,0.06)',
              animation: 'sbDialogIn 0.25s cubic-bezier(0.34,1.56,0.64,1) both',
            }}
          >
            {/* Glow */}
            <div
              aria-hidden="true"
              style={{
                position: 'absolute',
                inset: '-40% -30% auto',
                height: '200px',
                background:
                  'radial-gradient(ellipse at 50% 0%,rgba(0,242,254,0.08),transparent 70%)',
                pointerEvents: 'none',
              }}
            />

            {/* Icon */}
            <div
              style={{
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                width: '64px',
                height: '64px',
                margin: '0 auto 1.25rem',
                background: 'rgba(0,242,254,0.06)',
                border: '1px solid rgba(0,242,254,0.15)',
                borderRadius: '50%',
              }}
            >
              <span style={{ fontSize: '1.75rem' }}>🔍</span>
            </div>

            <h3
              id="sb-not-found-title"
              style={{
                color: '#fff',
                margin: '0 0 0.75rem',
                fontSize: '1.3rem',
                fontWeight: 700,
                letterSpacing: '-0.01em',
              }}
            >
              Compliance Not Available
            </h3>

            <p
              style={{
                color: 'rgba(255,255,255,0.7)',
                margin: '0 0 0.75rem',
                fontSize: '0.95rem',
                lineHeight: 1.6,
              }}
            >
              <strong style={{ color: '#00f2fe' }}>"{query}"</strong> is not
              available in the current version of M365 Advisor.
            </p>

            <p
              style={{
                color: 'rgba(255,255,255,0.38)',
                fontSize: '0.82rem',
                margin: '0 0 1.75rem',
                lineHeight: 1.65,
              }}
            >
              Currently supported:{' '}
              <em style={{ color: 'rgba(255,255,255,0.55)', fontStyle: 'normal' }}>
                CIS Benchmarks
              </em>
              ,{' '}
              <em style={{ color: 'rgba(255,255,255,0.55)', fontStyle: 'normal' }}>
                ISO/IEC 27001
              </em>
              ,{' '}
              <em style={{ color: 'rgba(255,255,255,0.55)', fontStyle: 'normal' }}>
                ISO/IEC 27002
              </em>
              ,{' '}
              <em style={{ color: 'rgba(255,255,255,0.55)', fontStyle: 'normal' }}>
                HIPPA
              </em>
              ,{' '}
              <em style={{ color: 'rgba(255,255,255,0.55)', fontStyle: 'normal' }}>
                RBI NBFC
              </em>
              , and{' '}
              <em style={{ color: 'rgba(255,255,255,0.55)', fontStyle: 'normal' }}>
                DPDP Act 2023
              </em>
              .
            </p>

            <div style={{ display: 'flex', gap: '0.75rem', justifyContent: 'center' }}>
              <button
                onClick={clearSearch}
                type="button"
                style={{
                  flex: 1,
                  maxWidth: '160px',
                  padding: '0.65rem 1.25rem',
                  borderRadius: '10px',
                  border: 'none',
                  background: 'linear-gradient(135deg,#00f2fe,#4facfe)',
                  color: '#050608',
                  fontWeight: 600,
                  cursor: 'pointer',
                  fontSize: '0.88rem',
                  fontFamily: 'inherit',
                  transition: 'transform 0.15s,box-shadow 0.15s',
                }}
                onMouseEnter={(e) => {
                  e.currentTarget.style.transform = 'translateY(-1px)';
                  e.currentTarget.style.boxShadow = '0 6px 20px rgba(0,242,254,0.3)';
                }}
                onMouseLeave={(e) => {
                  e.currentTarget.style.transform = 'none';
                  e.currentTarget.style.boxShadow = 'none';
                }}
              >
                Clear Search
              </button>
              <button
                onClick={() => setShowNotFound(false)}
                type="button"
                style={{
                  flex: 1,
                  maxWidth: '160px',
                  padding: '0.65rem 1.25rem',
                  borderRadius: '10px',
                  background: 'rgba(255,255,255,0.06)',
                  border: '1px solid rgba(255,255,255,0.1)',
                  color: 'rgba(255,255,255,0.75)',
                  fontWeight: 600,
                  cursor: 'pointer',
                  fontSize: '0.88rem',
                  fontFamily: 'inherit',
                }}
              >
                Dismiss
              </button>
            </div>
          </div>

          {/* Keyframe styles injected inline */}
          <style>{`
            @keyframes sbBackdropIn { from { opacity:0 } to { opacity:1 } }
            @keyframes sbDialogIn {
              from { opacity:0; transform:translate(-50%,-46%) scale(0.95) }
              to   { opacity:1; transform:translate(-50%,-50%) scale(1) }
            }
          `}</style>
        </>
      )}
    </>
  );
}
