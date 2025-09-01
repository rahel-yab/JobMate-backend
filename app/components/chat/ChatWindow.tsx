"use client";
import { useState } from "react";
import { ArrowLeft, Globe } from "lucide-react";
import ChatMessage from "./ChatMessage";
import { useLanguage } from "@/context/language-provider";
import QuickActions from "./QuickActions";
import { formatTime } from "@/lib/utils";
import ChatInput from "./ChatInput";
//import { message } from "@/lib/types";

export default function ChatWindow() {
  const { language, setLanguage, t } = useLanguage();

  const [messages, setMessages] = useState<any[]>([
    {
      id: "1",
      type: "text",
      text: t("welcomeMessage"),
      sender: "ai",
      time: formatTime(),
    },
  ]);

  const [input, setInput] = useState("");
  const [mode, setMode] = useState<
    "cv" | "jobs" | "interview" | "skills" | "chat"
  >("chat");
  const [cvPromptVisible, setCvPromptVisible] = useState(false);

  const handleQuickAction = (
    action: "cv" | "jobs" | "interview" | "skills"
  ) => {
    const actionMessages = {
      cv:
        language === "en"
          ? "I'd like help reviewing my CV and getting feedback on how to improve it."
          : "CVዬን በመገምገም እና እንዴት ማሻሻል እንደምችል ግብረመልስ ማግኘት እፈልጋለሁ።",
      jobs:
        language === "en"
          ? "Can you help me find job opportunities that match my skills?"
          : "ከችሎታዎቼ ጋር የሚስማሙ የስራ እድሎችን እንዳገኝ ልትረዱኝ ትችላላችሁ?",
      interview:
        language === "en"
          ? "I want to practice interview questions and get feedback on my answers."
          : "የቃለመጠይቅ ጥያቄዎችን መለማመድ እና በመልሶቼ ላይ ግብረመልስ ማግኘት እፈልጋለሁ።",
      skills:
        language === "en"
          ? "I'd like to assess my skills and get a personalized learning path."
          : "ችሎታዎችዎን ለመገምገም እና የግል የመማሪያ መንገድ ለማግኘት እፈልጋለሁ።",
    };
    setMode(action);
    setInput(actionMessages[action]);
  };

  return (
    <div className="flex flex-col w-full h-screen bg-white">
      {/* Header */}
      <div className="flex items-center justify-between h-[80px] shadow px-4  bg-[#217C6A] text-white">
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

      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {messages.map((msg) => (
          <ChatMessage key={msg.id} {...msg} />
        ))}
      </div>

      {/* Input Area */}
      <div className="px-4 py-4 bg-[#BEE3DC] text-black justify-center">
        <QuickActions handleQuickAction={handleQuickAction} />
        <ChatInput
          input={input}
          setInput={setInput}
          setMessages={setMessages}
          mode={mode}
          cvPromptVisible={cvPromptVisible}
          setCvPromptVisible={setCvPromptVisible}
        />
      </div>
    </div>
  );
}
