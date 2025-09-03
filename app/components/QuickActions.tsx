"use client";
import { FileText, Briefcase, MessageCircle } from "lucide-react";
import { Button } from "./ui/Button";
import { useLanguage } from "@/providers/language-provider";

interface QuickActionsProps {
  handleQuickAction: (type: string) => void;
}

export default function QuickActions({ handleQuickAction }: QuickActionsProps) {
  const { t, language } = useLanguage();

  return (
    <div className="p-3 sm:p-4  bg-card">
      <div className="flex gap-1 sm:gap-2 mb-3 sm:mb-4 overflow-x-auto pb-1">
        <Button
          variant="outline"
          size="sm"
          onClick={() => handleQuickAction("cv")}
          className="flex items-center gap-1 sm:gap-2 whitespace-nowrap text-xs sm:text-sm px-2 sm:px-3 py-1 sm:py-2 flex-shrink-0 bg-white shadow-md border-0"
        >
          <FileText className="h-3 w-3 sm:h-4 sm:w-4" />
          <span className="hidden xs:inline">{t("cvReview")}</span>
          <span className="xs:hidden">CV</span>
        </Button>

        <Button
          variant="outline"
          size="sm"
          onClick={() => handleQuickAction("jobs")}
          className="flex items-center gap-1 sm:gap-2 whitespace-nowrap text-xs sm:text-sm px-2 sm:px-3 py-1 sm:py-2 flex-shrink-0 bg-white shadow-md border-0"
        >
          <Briefcase className="h-3 w-3 sm:h-4 sm:w-4" />
          <span className="hidden xs:inline">{t("findJobs")}</span>
          <span className="xs:hidden">{language === "en" ? "Jobs" : "ስራ"}</span>
        </Button>

        <Button
          variant="outline"
          size="sm"
          onClick={() => handleQuickAction("interview")}
          className="flex items-center gap-1 sm:gap-2 whitespace-nowrap text-xs sm:text-sm px-2 sm:px-3 py-1 sm:py-2 flex-shrink-0 bg-white shadow-md border-0"
        >
          <MessageCircle className="h-3 w-3 sm:h-4 sm:w-4" />
          <span className="hidden xs:inline">{t("interviewPractice")}</span>
          <span className="xs:hidden">
            {language === "en" ? "Interview" : "ቃለመጠይቅ"}
          </span>
        </Button>

        <Button
          variant="outline"
          size="sm"
          onClick={() => handleQuickAction("skills")}
          className="flex items-center gap-1 sm:gap-2 whitespace-nowrap text-xs sm:text-sm px-2 sm:px-3 py-1 sm:py-2 flex-shrink-0 bg-white shadow-md border-0"
        >
          <Briefcase className="h-3 w-3 sm:h-4 sm:w-4" />
          <span className="hidden xs:inline">
            {language === "en" ? "Skills" : "ችሎታዎች"}
          </span>
          <span className="xs:hidden">
            {language === "en" ? "Skills" : "ችሎታዎች"}
          </span>
        </Button>
      </div>
    </div>
  );
}
