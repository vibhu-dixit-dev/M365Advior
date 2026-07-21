import React from "react";
import { Card, Title, List, ListItem } from "@tremor/react";
import { Lock } from "lucide-react";

export default function PremiumModuleCard({ title, items }) {
  const subject = encodeURIComponent(`Access Request: Premium Module - ${title}`);
  const body = encodeURIComponent(
    `Hi Salman,\n\nI want to access this premium ${title} auditing module in M365Advisor. Please provide me with the details on how to get started.\n\nThanks!`
  );
  const mailtoUrl = `mailto:Salman.Sayyed@onmeridian.com?subject=${subject}&body=${body}`;

  const handleClick = () => {
    window.location.href = mailtoUrl;
  };

  return (
    <Card 
      onClick={handleClick}
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
  );
}
