"use client";
import { ArrowLeft, Globe } from "lucide-react";
import { useLanguage } from "@/providers/language-provider";
import QuickActions from "../QuickActions";

export default function ChatWindow({
  messages,
  onQuickAction,
  renderMessage,
}: {
  messages: any[];

  onQuickAction?: () => void;
  renderMessage: (msg: any) => React.ReactNode;
}) {
  const { language, setLanguage, t } = useLanguage();

  return (
    <div className="flex flex-col w-full h-screen bg-white">
      <div className="flex items-center justify-between h-[80px] shadow px-4 bg-[#217C6A] text-white">
        <div className="flex items-center gap-3">
          <ArrowLeft className="h-5 w-5 text-white cursor-pointer" />
          <div className="h-10 w-10 bg-[#0F3A31] text-white rounded-full flex items-center justify-center font-bold">
            JM
          </div>
          <div>
            <span className="font-semibold text-lg block">{t("appTitle")}</span>
            <span className="text-sm text-white/70">{t("appSubtitle")}</span>
          </div>
        </div>

        <div className="flex items-center bg-white rounded-md shadow-md px-2 gap-1 py-1">
          <button onClick={() => setLanguage(language === "en" ? "am" : "en")}>
            <Globe className="h-5 w-5 text-[#0F3A31]" />
          </button>
          <p className="text-black font-bold text-sm">
            {language === "en" ? t("switchToAmharic") : "EN"}
          </p>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {messages.map((msg) => renderMessage(msg))}
      </div>

      <div className="px-4 py-0.5 bg-[#BEE3DC] text-black justify-center">
        <QuickActions onQuickAction={onQuickAction} />
      </div>
    </div>
  );
}
