"use client";
import { useState, useEffect } from "react";
import { ArrowLeft, Globe, Send } from "lucide-react";
import ChatMessage from "./ChatMessage";
import { useLanguage } from "@/context/language-provider";

const formatTime = () => {
  return new Date().toLocaleTimeString([], {
    hour: "2-digit",
    minute: "2-digit",
  });
};

export default function ChatWindow() {
  const { language, setLanguage, t } = useLanguage();
  const [messages, setMessages] = useState<any[]>([
    {
      id: 1,
      text: t("welcomeMessage"),
      sender: "ai",
      time: formatTime(),
    },
  ]);

  const [input, setInput] = useState("");

  const sendMessage = () => {
    if (!input.trim()) return;

    const newMsg = {
      id: Date.now(),
      text: input,
      sender: "user",
      time: formatTime(),
    };
    setMessages([...messages, newMsg]);

    setTimeout(() => {
      setMessages((prev) => [
        ...prev,
        {
          id: Date.now(),
          text: t("welcomeMessage"),
          sender: "ai",
          time: formatTime(),
        },
      ]);
    }, 1000);

    setInput("");
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
            <span className="font-semibold text-lg  block">
              {t("appTitle")}
            </span>
            <span className="text-sm text-white/70 ">{t("appSubtitle")}</span>
          </div>
        </div>

        <div className="flex items-center bg-white rounded-md shadow-md px-2 gap-1 py-1 ">
          <button
            onClick={() => setLanguage(language === "en" ? "am" : "en")}
            className=""
          >
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
          <ChatMessage
            key={msg.id}
            text={msg.text}
            sender={msg.sender}
            time={msg.time}
          />
        ))}
      </div>

      {/* Input */}
      <div className="flex items-center gap-2 px-4 py-4  bg-[#BEE3DC] text-black">
        <input
          className="flex-1 bg-white shadow-md rounded-md px-4 py-2.5 focus:outline-none focus:shadow-[0_0_8px_2px_rgba(40,149,127,0.7)]"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && sendMessage()}
          placeholder={
            language === "en" ? "Type a message..." : "መልእክት ያድርጉ..."
          }
        />

        <button
          onClick={sendMessage}
          className="bg-[#0F3A31] hover:bg-[#217C6A] p-3 rounded-lg text-white flex items-center justify-center"
        >
          <Send className="h-5 w-5" />
        </button>
      </div>
    </div>
  );
}
