"use client";
import React, { useState, useEffect, useRef } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { useGetFreeformHistoryQuery } from "@/lib/redux/api/interviewApi"; // Adjust import path accordingly

interface Message {
  sender: "user" | "ai";
  text: string;
}

const texts = {
  en: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    historyTitle: "Freeform Interview Chat History",
    chatIdLabel: "Chat ID",
    loading: "Loading chat history...",
    noChatId: "No chat ID found.",
    loadError: "Unable to load chat history.",
  },
  am: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    historyTitle: "የቃለ መጠይቅ ቻት ታሪክ",
    chatIdLabel: "የቻት መለያ",
    loading: "የቻት ታሪክ በመጫን ላይ...",
    noChatId: "የቻት መለያ አልተገኘም።",
    loadError: "የቻት ታሪኩን መጫን አልተቻለም።",
  },
};

const FreeformChatHistory: React.FC = () => {
  const [language, setLanguage] = useState<"en" | "am">("en");
  const router = useRouter();
  const searchParams = useSearchParams();
  const chatId = searchParams.get("chatid");
  const t = texts[language];

  const messagesEndRef = useRef<HTMLDivElement | null>(null);

  // Use the new RTK Query hook with skip option
  const { data, error, isLoading } = useGetFreeformHistoryQuery(chatId ?? "", {
    skip: !chatId,
  });

  // Redirect if no chatId
  useEffect(() => {
    if (!chatId) {
      alert(t.noChatId);
      router.push("/interview");
    }
  }, [chatId, router, t.noChatId]);

  // Scroll to bottom on new data
  useEffect(() => {
    if (data) {
      messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    }
  }, [data]);

  // Map API response to messages array
  const messages: Message[] =
    data?.data?.messages.map((msg: any) => ({
      sender: msg.role === "assistant" ? "ai" : "user",
      text: msg.content || msg.text || "",
    })) || [];

  // Handle error by alert + redirect
  useEffect(() => {
    if (error) {
      alert(t.loadError);
      router.push("/interview");
    }
  }, [error, router, t.loadError]);

  return (
    <div className="min-h-screen bg-gray-50 font-sans text-gray-800">
      {/* Header */}
      <header className="flex items-center justify-between h-[80px] shadow px-4 bg-[#217C6A] text-white">
        <div className="flex items-center gap-3">
          <div
            className="h-5 w-5 text-white cursor-pointer"
            onClick={() => router.push("/interview")}
          >
            ←
          </div>
          <div className="h-10 w-10 bg-[#0F3A31] text-white rounded-full flex items-center justify-center font-bold">
            JM
          </div>
          <div>
            <span className="font-semibold text-lg block">{t.jobMate}</span>
            <span className="text-sm text-white/70">{t.slogan}</span>
          </div>
        </div>
        <div className="flex items-center bg-white rounded-md shadow-md px-2 gap-1 py-1">
          <button
            onClick={() => setLanguage((prev) => (prev === "en" ? "am" : "en"))}
            aria-label="Toggle language"
          >
            <div className="h-5 w-5 text-[#0F3A31]">🌐</div>
          </button>
          <p className="text-black font-bold text-sm">
            {language === "en" ? "አማ" : "EN"}
          </p>
        </div>
      </header>

      {/* Chat Container */}
      <div className="relative max-w-3xl mx-auto px-4 pt-6 pb-28 min-h-[70vh]">
        {/* Page Title */}
        <header className="mb-4 pb-4 border-b border-gray-200">
          <h1 className="text-xl font-semibold">{t.historyTitle}</h1>
          <p className="text-gray-500 text-sm">
            {t.chatIdLabel}: {chatId}
          </p>
        </header>

        {isLoading ? (
          <p className="text-center text-gray-600 mt-20">{t.loading}</p>
        ) : (
          <div className="space-y-4 overflow-y-auto max-h-[60vh]">
            {messages.map((msg, idx) => (
              <div
                key={idx}
                className={`flex ${
                  msg.sender === "ai" ? "justify-start" : "justify-end"
                }`}
              >
                <div
                  className={`max-w-xs md:max-w-md p-3 rounded-xl ${
                    msg.sender === "ai"
                      ? "bg-blue-100 text-gray-800 rounded-bl-none"
                      : "bg-blue-600 text-white rounded-br-none"
                  }`}
                >
                  {msg.text}
                </div>
              </div>
            ))}
            <div ref={messagesEndRef} />
          </div>
        )}
      </div>
    </div>
  );
};

export default FreeformChatHistory;
