"use client";
import {
  FileText,
  Briefcase,
  MessageCircle,
  MessageSquare,
} from "lucide-react";
import { Button } from "./ui/Button";
import { useLanguage } from "@/providers/language-provider";
import { useRouter, usePathname } from "next/navigation";

export default function QuickActions() {
  const { t, language } = useLanguage();
  const router = useRouter();
  const pathname = usePathname();

  const handleQuickAction = (action: string, path: string) => {
    if (pathname !== path) {
      router.push(path);
    }
  };

  const actions = [
    {
      key: "cv",
      path: "/cv",
      label: t("cvReview"),
      short: "CV",
      icon: <FileText className="h-3 w-3 sm:h-4 sm:w-4" />,
    },
    {
      key: "jobs",
      path: "/chat/jobsearch",
      label: t("findJobs"),
      short: language === "en" ? "Jobs" : "ስራ",
      icon: <Briefcase className="h-3 w-3 sm:h-4 sm:w-4" />,
    },
    {
      key: "interview",
      path: "/interview",
      label: t("interviewPractice"),
      short: language === "en" ? "Interview" : "ቃለመጠይቅ",
      icon: <MessageCircle className="h-3 w-3 sm:h-4 sm:w-4" />,
    },
  ];

  return (
    <div className="p-3 sm:p-4 bg-card">
      <div className="flex gap-1 sm:gap-2 mb-3 sm:mb-4 overflow-x-auto pb-1">
        {actions.map(({ key, path, label, short, icon }) => {
          const isActive = pathname === path;
          return (
            <Button
              key={key}
              variant={isActive ? "default" : "outline"}
              size="sm"
              disabled={isActive}
              onClick={() => handleQuickAction(key, path)}
              className={`flex items-center gap-1 sm:gap-2 whitespace-nowrap text-xs sm:text-sm px-2 sm:px-3 py-1 sm:py-2 flex-shrink-0 shadow-md border-0 ${
                isActive
                  ? "bg-[#217C6A]  text-white cursor-default"
                  : "bg-white hover:bg-[#99bfb8]"
              }`}
            >
              {icon}
              <span className="hidden xs:inline">{label}</span>
              <span className="xs:hidden">{short}</span>
            </Button>
          );
        })}
      </div>
    </div>
  );
}
