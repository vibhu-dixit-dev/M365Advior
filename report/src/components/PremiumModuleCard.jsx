import React, { useState, useEffect } from "react";
import { Card, Title, List, ListItem } from "@tremor/react";
import { Lock, Mail, ExternalLink, X } from "lucide-react";

export default function PremiumModuleCard({ title, items }) {
  const [isOpen, setIsOpen] = useState(false);
  const recipient = "Salman.Sayyed@onmeridian.com";
  const subject = encodeURIComponent(`Access Request: Premium Module - ${title}`);
  const body = encodeURIComponent(
    `Hi Salman,\n\nI want to access this premium ${title} auditing module in M365Advisor. Please provide me with the details on how to get started.\n\nThanks!`
  );
  const mailtoUrl = `mailto:${recipient}?subject=${subject}&body=${body}`;

  useEffect(() => {
    if (!isOpen) return;
    const handleKeyDown = (e) => {
      if (e.key === "Escape") setIsOpen(false);
    };
    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [isOpen]);

  const handleProceed = () => {
    setIsOpen(false);
    window.location.href = mailtoUrl;
  };

  return (
    <>
      <Card 
        onClick={() => setIsOpen(true)}
        className="relative cursor-pointer transition-all duration-200 hover:shadow-md hover:border-orange-200 group overflow-hidden border border-gray-200 dark:border-gray-800"
      >
        {/* Premium Badge/Banner on top right */}
        <div className="absolute top-3 right-3">
          <span className="inline-flex items-center gap-1 rounded bg-orange-100 px-2 py-0.5 text-xs font-semibold text-orange-800 dark:bg-orange-950/50 dark:text-orange-400 border border-orange-200 dark:border-orange-900/50">
            <Lock className="size-3" /> PREMIUM
          </span>
        </div>

        <Title className="pr-20 text-gray-900 dark:text-gray-100">{title}</Title>
        
        <div className="mt-4 relative">
          {/* Mock content list representing categories */}
          <List className="opacity-60 group-hover:opacity-80 transition-opacity">
            {items.map((item, index) => (
              <ListItem key={index} className="space-x-2 py-2">
                <div className="flex items-center space-x-2 truncate">
                  <span className="h-2 w-2 rounded-full flex-shrink-0 bg-gray-300 dark:bg-gray-700" />
                  <span className="truncate text-sm text-gray-600 dark:text-gray-400">{item.name}</span>
                </div>
                <span className="text-xs font-medium text-gray-500">{item.checks} checks</span>
              </ListItem>
            ))}
          </List>
          
          {/* Subtle hover call-to-action */}
          <div className="mt-4 text-center opacity-0 group-hover:opacity-100 transition-opacity duration-200">
            <span className="text-xs font-medium text-orange-600 dark:text-orange-400">
              Click to Request Access &rarr;
            </span>
          </div>
        </div>
      </Card>

      {/* Center Confirmation Pop-up */}
      {isOpen && (
        <div 
          className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm animate-in fade-in duration-150"
          onClick={() => setIsOpen(false)}
          role="dialog"
          aria-modal="true"
        >
          <div 
            className="w-full max-w-md bg-white dark:bg-gray-900 border border-orange-500/30 rounded-2xl p-6 shadow-2xl relative text-center animate-in zoom-in-95 duration-150"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Close icon button */}
            <button
              onClick={() => setIsOpen(false)}
              className="absolute top-4 right-4 p-1.5 rounded-lg text-gray-400 hover:text-gray-600 dark:hover:text-gray-200 hover:bg-gray-100 dark:hover:bg-gray-800 transition-colors"
              aria-label="Close"
              type="button"
            >
              <X className="size-4" />
            </button>

            {/* Icon */}
            <div className="mx-auto mb-4 flex size-14 items-center justify-center rounded-full bg-orange-100 text-orange-600 dark:bg-orange-950/60 dark:text-orange-400 border border-orange-300/40 shadow-lg shadow-orange-500/10">
              <Mail className="size-6" />
            </div>

            {/* Title */}
            <h3 className="text-lg font-bold text-gray-900 dark:text-white mb-2">
              Redirecting to Mailbox
            </h3>

            {/* Message */}
            <p className="text-sm text-gray-600 dark:text-gray-300 leading-relaxed mb-4">
              You are being redirected to your mailbox to request access to the <strong className="text-orange-600 dark:text-orange-400 font-semibold">{title}</strong> premium feature.
            </p>

            {/* Preview Box */}
            <div className="bg-gray-50 dark:bg-gray-950/70 border border-gray-200 dark:border-gray-800 rounded-xl p-3.5 mb-6 text-left text-xs space-y-1.5">
              <div className="flex gap-2">
                <span className="text-gray-400 dark:text-gray-500 font-medium w-14 shrink-0">To:</span>
                <span className="text-gray-800 dark:text-gray-200 font-mono break-all">{recipient}</span>
              </div>
              <div className="flex gap-2">
                <span className="text-gray-400 dark:text-gray-500 font-medium w-14 shrink-0">Subject:</span>
                <span className="text-gray-800 dark:text-gray-200 break-all">Access Request: Premium Module - {title}</span>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="flex items-center gap-3">
              <button
                type="button"
                onClick={() => setIsOpen(false)}
                className="flex-1 px-4 py-2.5 rounded-xl border border-gray-300 dark:border-gray-700 bg-transparent text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800 font-semibold text-sm transition-colors cursor-pointer"
              >
                Decline
              </button>
              <button
                type="button"
                onClick={handleProceed}
                className="flex-1 px-4 py-2.5 rounded-xl bg-orange-600 hover:bg-orange-500 text-white font-semibold text-sm shadow-md shadow-orange-600/30 transition-all hover:-translate-y-0.5 cursor-pointer flex items-center justify-center gap-1.5"
                autoFocus
              >
                <span>Proceed</span>
                <ExternalLink className="size-3.5" />
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
