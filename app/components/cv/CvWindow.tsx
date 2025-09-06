"use client";
import { ArrowLeft, Globe } from "lucide-react";
import { useLanguage } from "@/providers/language-provider";
import QuickActions from "../QuickActions";
import ChatInput from "./ChatInput";
import { useRef, useEffect } from "react";

export default function ChatWindow({
  messages,
  renderMessage,
  input,
  setInput,
  onSend,
  onBack,
}: {
  messages: any[];
  renderMessage: (msg: any) => React.ReactNode;
  input: string;
  setInput: (val: string) => void;
  onSend: () => void;
  onBack?: () => void;
}) {
  const { language, setLanguage, t } = useLanguage();

  const messagesEndRef = useRef<HTMLDivElement | null>(null);
  const initialRender = useRef(true); // ✅ track first render

  useEffect(() => {
    if (!messagesEndRef.current) return;

    if (initialRender.current) {
      // Jump immediately to the newest messages on first render
      messagesEndRef.current.scrollIntoView({ behavior: "auto" });
      initialRender.current = false;
    } else {
      // Smooth scroll for new messages
      messagesEndRef.current.scrollIntoView({ behavior: "smooth" });
    }
  }, [messages]);

  return (
    <div className="flex flex-col w-full h-screen bg-white">
      <div className="flex items-center justify-between h-[80px] shadow px-4 bg-[#217C6A] text-white">
        <div className="flex items-center gap-3">
          <ArrowLeft
            className="h-5 w-5 text-white cursor-pointer"
            onClick={onBack}
          />
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
        <div ref={messagesEndRef} /> {/* scroll anchor */}
      </div>

      <div className="px-4 py-0.5 bg-[#BEE3DC] text-black justify-center">
        <QuickActions />
        <ChatInput input={input} setInput={setInput} onSend={onSend} />
      </div>
    </div>
  );
}
