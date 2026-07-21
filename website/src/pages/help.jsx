import React, { useState, useRef } from 'react';
import Layout from '@theme/Layout';
import emailjs from '@emailjs/browser';
import styles from './help.module.css';

// ─── EmailJS Configuration ────────────────────────────────────────────────────
// Replace these three values with your own EmailJS credentials:
//   1. Sign up at https://www.emailjs.com (free tier: 200 emails/month)
//   2. Create a Service → copy the Service ID
//   3. Create an Email Template with variables:
//        {{from_title}}, {{from_name}}, {{from_company}}, {{reply_to}}, {{message}}
//      Set "To Email" in the template to: vibhu.dixit@onmeridian.com
//   4. Copy your Public Key from Account → API Keys
const EMAILJS_SERVICE_ID = 'service_wv8v1de';   // e.g. 'service_abc123'
const EMAILJS_TEMPLATE_ID = 'template_vhbxs43';  // e.g. 'template_xyz789'
const EMAILJS_PUBLIC_KEY = 'gdbvLSvf4cSKEskpl';   // e.g. 'AbCdEfGhIjKlMnOp'
// ─────────────────────────────────────────────────────────────────────────────

const INITIAL = {
  title: '',
  name: '',
  company: '',
  email: '',
  message: '',
};

export default function HelpPage() {
  const formRef = useRef(null);
  const [form, setForm] = useState(INITIAL);
  const [status, setStatus] = useState('idle'); // idle | sending | success | error
  const [errorMsg, setErrorMsg] = useState('');

  const handleChange = (e) => {
    setForm((prev) => ({ ...prev, [e.target.name]: e.target.value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setStatus('sending');
    setErrorMsg('');

    try {
      await emailjs.send(
        EMAILJS_SERVICE_ID,
        EMAILJS_TEMPLATE_ID,
        {
          from_title: form.title,
          from_name: form.name,
          from_company: form.company,
          reply_to: form.email,
          message: form.message,
          to_email: 'vibhu.dixit@onmeridian.com',
        },
        EMAILJS_PUBLIC_KEY
      );
      setStatus('success');
      setForm(INITIAL);
    } catch (err) {
      console.error('EmailJS error:', err);
      setStatus('error');
      setErrorMsg(err?.text || 'Something went wrong. Please try again later.');
    }
  };

  const resetForm = () => {
    setStatus('idle');
    setErrorMsg('');
  };

  return (
    <Layout
      title="Help &amp; Support"
      description="Request help from the M365 Advisor team. Fill in the form and we'll get back to you shortly."
    >
      <main className={styles.main}>
        {/* ── Header ── */}
        <div className={styles.header}>
          <div className={styles.iconWrap}>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
              stroke="currentColor" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round"
              className={styles.headerIcon}>
              <circle cx="12" cy="12" r="10" />
              <path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3" />
              <line x1="12" y1="17" x2="12.01" y2="17" />
            </svg>
          </div>
          <h1 className={styles.title}>How can we help?</h1>
          <p className={styles.subtitle}>
            Fill in the form below and the M365 Advisor team will get back to you as soon as possible.
          </p>
        </div>

        {/* ── Card ── */}
        <div className={styles.card}>

          {/* ── Success State ── */}
          {status === 'success' && (
            <div className={styles.successState}>
              <div className={styles.successIconWrap}>
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                  stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                  <polyline points="22 4 12 14.01 9 11.01" />
                </svg>
              </div>
              <h2 className={styles.successTitle}>Request Sent!</h2>
              <p className={styles.successMsg}>
                Thanks for reaching out. We've received your message and will reply to&nbsp;
                <strong>{form.email || 'your email'}</strong> shortly.
              </p>
              <button className={styles.resetBtn} onClick={resetForm}>
                Send Another Request
              </button>
            </div>
          )}

          {/* ── Form ── */}
          {status !== 'success' && (
            <form ref={formRef} onSubmit={handleSubmit} className={styles.form} noValidate>

              {/* Title */}
              <div className={styles.field}>
                <label htmlFor="help-title" className={styles.label}>
                  Request Title <span className={styles.required}>*</span>
                </label>
                <input
                  id="help-title"
                  name="title"
                  type="text"
                  className={styles.input}
                  placeholder="e.g. Issue with CIS benchmark tests"
                  value={form.title}
                  onChange={handleChange}
                  required
                  disabled={status === 'sending'}
                />
              </div>

              {/* Name + Company row */}
              <div className={styles.row}>
                <div className={styles.field}>
                  <label htmlFor="help-name" className={styles.label}>
                    Your Name <span className={styles.required}>*</span>
                  </label>
                  <input
                    id="help-name"
                    name="name"
                    type="text"
                    className={styles.input}
                    placeholder="Jane Smith"
                    value={form.name}
                    onChange={handleChange}
                    required
                    disabled={status === 'sending'}
                  />
                </div>

                <div className={styles.field}>
                  <label htmlFor="help-company" className={styles.label}>
                    Company Name <span className={styles.required}>*</span>
                  </label>
                  <input
                    id="help-company"
                    name="company"
                    type="text"
                    className={styles.input}
                    placeholder="Acme Corporation"
                    value={form.company}
                    onChange={handleChange}
                    required
                    disabled={status === 'sending'}
                  />
                </div>
              </div>

              {/* Company Email */}
              <div className={styles.field}>
                <label htmlFor="help-email" className={styles.label}>
                  Company Email <span className={styles.required}>*</span>
                </label>
                <input
                  id="help-email"
                  name="email"
                  type="email"
                  className={styles.input}
                  placeholder="jane@company.com"
                  value={form.email}
                  onChange={handleChange}
                  required
                  disabled={status === 'sending'}
                />
              </div>

              {/* Message */}
              <div className={styles.field}>
                <label htmlFor="help-message" className={styles.label}>
                  Message <span className={styles.required}>*</span>
                </label>
                <textarea
                  id="help-message"
                  name="message"
                  className={styles.textarea}
                  placeholder="Describe what you need help with in detail…"
                  rows={6}
                  value={form.message}
                  onChange={handleChange}
                  required
                  disabled={status === 'sending'}
                />
              </div>

              {/* Error banner */}
              {status === 'error' && (
                <div className={styles.errorBanner}>
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                    stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"
                    className={styles.errorIcon}>
                    <circle cx="12" cy="12" r="10" />
                    <line x1="12" y1="8" x2="12" y2="12" />
                    <line x1="12" y1="16" x2="12.01" y2="16" />
                  </svg>
                  <span>{errorMsg || 'Failed to send. Please try again.'}</span>
                </div>
              )}

              {/* Submit */}
              <button
                id="help-submit"
                type="submit"
                className={styles.submitBtn}
                disabled={status === 'sending'}
              >
                {status === 'sending' ? (
                  <>
                    <span className={styles.spinner} />
                    Sending…
                  </>
                ) : (
                  <>
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none"
                      stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"
                      className={styles.sendIcon}>
                      <line x1="22" y1="2" x2="11" y2="13" />
                      <polygon points="22 2 15 22 11 13 2 9 22 2" />
                    </svg>
                    Send Request
                  </>
                )}
              </button>

              <p className={styles.privacy}>
                Your information is used solely to respond to your request and will never be shared.
              </p>
            </form>
          )}
        </div>
      </main>
    </Layout>
  );
}
