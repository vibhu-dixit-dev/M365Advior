import React, { useEffect } from 'react';
import clsx from 'clsx';
import styles from './styles.module.css';

export default function PremiumConfirmModal({
  isOpen,
  onClose,
  title = "Premium Feature",
  recipient = "Salman.Sayyed@onmeridian.com",
  mailtoUrl,
}) {
  useEffect(() => {
    if (!isOpen) return;
    const handleKeyDown = (e) => {
      if (e.key === 'Escape') onClose();
    };
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, onClose]);

  if (!isOpen) return null;

  const defaultMailto = mailtoUrl || `mailto:${recipient}?subject=${encodeURIComponent(`Access Request: Premium Module - ${title}`)}&body=${encodeURIComponent(`Hi Salman,\n\nI want to access this premium ${title} auditing module in M365Advisor. Please provide me with the details on how to get started.\n\nThanks!`)}`;

  const handleProceed = () => {
    onClose();
    window.location.href = defaultMailto;
  };

  return (
    <div className={styles.backdrop} onClick={onClose} role="dialog" aria-modal="true">
      <div className={styles.modal} onClick={(e) => e.stopPropagation()}>
        <div className={styles.iconWrapper}>
          <span className={styles.icon}>🔒</span>
        </div>

        <h3 className={styles.title}>Redirecting to Mailbox</h3>

        <p className={styles.message}>
          You are being redirected to your mailbox to request access to the <strong>{title}</strong> premium feature.
        </p>

        <div className={styles.infoBox}>
          <div className={styles.infoRow}>
            <span className={styles.infoLabel}>To:</span>
            <span className={styles.infoValue}>{recipient}</span>
          </div>
          <div className={styles.infoRow}>
            <span className={styles.infoLabel}>Subject:</span>
            <span className={styles.infoValue}>Access Request: Premium Module - {title}</span>
          </div>
        </div>

        <div className={styles.actions}>
          <button
            type="button"
            className={clsx(styles.btn, styles.btnDecline)}
            onClick={onClose}
          >
            Decline
          </button>
          <button
            type="button"
            className={clsx(styles.btn, styles.btnProceed)}
            onClick={handleProceed}
            autoFocus
          >
            Proceed ✉️
          </button>
        </div>
      </div>
    </div>
  );
}
