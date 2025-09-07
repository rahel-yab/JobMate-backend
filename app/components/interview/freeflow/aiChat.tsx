"use client";

import React, { useState, useEffect, useRef } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import {
  useCreateFreeformSessionMutation,
  useSendFreeformMessageMutation,
  useGetFreeformUserChatsQuery,
} from "@/lib/redux/api/interviewApi"; // Adjust path as needed

type Role = "user" | "ai";

interface Message {
  sender: Role;
  text: string;
}

const texts = {
  en: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    freeformTitle: "Freeform Interview Chat",
    sessionTypeLabel: "Session Type",
    typing: "Typing...",
    placeholder: "Type your message...",
  },
  am: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    freeformTitle: "ነጻ ቃለ መጠይቅ ቻት",
    sessionTypeLabel: "የክፍል አይነት",
    typing: "በማዘጋጀት ላይ...",
    placeholder: "መልእክትዎን ያስገቡ...",
  },
};

const FreeformChatPage: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [inputValue, setInputValue] = useState("");
  const [language, setLanguage] = useState<"en" | "am">("en");
  const [sessionId, setSessionId] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const [createSession] = useCreateFreeformSessionMutation();
  const [sendMessage] = useSendFreeformMessageMutation();

  const router = useRouter();
  const searchParams = useSearchParams();
  const sessionType = searchParams.get("session") || "general";
  const messagesEndRef = useRef<HTMLDivElement | null>(null);

  const t = texts[language];
  const { data: userChatsData, isLoading: chatsLoading } =
    useGetFreeformUserChatsQuery();
 

  useEffect(() => {
    const startSession = async () => {
      if (!userChatsData || sessionId) return; // ✅ Prevent duplicate creation on reload or lang change

      try {
        const userChats = userChatsData?.data?.chats;

        if (Array.isArray(userChats)) {
          const existingSession = userChats.find(
            (chat: any) => chat.session_type === sessionType
          );

          if (existingSession) {
            setSessionId(existingSession.chat_id);
            setMessages([
              {
                sender: "ai",
                text:
                  language === "en"
                    ? "Welcome back! You can continue your conversation."
                    : "እንኳን ደህና መጣችሁ! ቀደም ሲል ያለበትን ውይይት ይቀጥሉ።",
              },
            ]);
          } else {
            const res = await createSession({
              user_id: "demo-user-id", // Replace with real user ID
              session_type: sessionType,
            }).unwrap();

            const chatId = res?.data?.chat_id;
            const initialMessage = res?.data?.message;

            if (chatId) {
              setSessionId(chatId);
              setMessages([
                {
                  sender: "ai",
                  text:
                    initialMessage ||
                    (language === "en"
                      ? "Hello! I'm your AI interview coach. What would you like to explore today?"
                      : "ሰላም! እኔ የኤ.አይ ቃለ መጠይቅ አማራጭዎ ነኝ። ዛሬ ምን ማወቅ እፈልጋለሁ?"),
                },
              ]);
            }
          }
        }
      } catch (error) {
        console.error("Failed to start or load session:", error);
      }
    };

    startSession();
  }, [userChatsData, sessionType]); 

  // useEffect(() => {
  //   const startSession = async () => {
  //     try {
  //       const res = await createSession({
  //         user_id: "demo-user-id", // Replace with actual user ID
  //         session_type: sessionType,
  //       }).unwrap();

  //       const chatId = res?.data?.chat_id;
  //       const initialMessage = res?.data?.message;

  //       if (chatId) {
  //         setSessionId(chatId);
  //         setMessages([
  //           {
  //             sender: "ai",
  //             text:
  //               initialMessage ||
  //               (language === "en"
  //                 ? "Hello! I'm your AI interview coach. What would you like to explore today?"
  //                 : "ሰላም! እኔ የኤ.አይ ቃለ መጠይቅ አማራጭዎ ነኝ። ዛሬ ምን ማወቅ እፈልጋለሁ?"),
  //           },
  //         ]);
  //       }
  //     } catch (error) {
  //       console.error("Failed to start session:", error);
  //     }
  //   };

  //   startSession();
  // }, [language, sessionType, createSession]);

  const handleSendMessage = async () => {
    if (!inputValue.trim() || !sessionId) return;

    const userMsg: Message = { sender: "user", text: inputValue.trim() };
    setMessages((prev) => [...prev, userMsg]);
    setInputValue("");
    setIsLoading(true);

    try {
      const res = await sendMessage({
        chat_id: sessionId,
        message: userMsg.text,
      }).unwrap();
      console.log("data:", res);
      const botMsg = res?.data;

      if (botMsg) {
        const aiMessage: Message = {
          sender: botMsg?.role === "assistant" ? "ai" : "user",
          text: botMsg?.content || "No response content",
        };

        setMessages((prev) => [...prev, aiMessage]);
      }
    } catch (error) {
      console.error("Failed to send message:", error);
      setMessages((prev) => [
        ...prev,
        {
          sender: "ai",
          text:
            language === "en"
              ? "Something went wrong — try again shortly."
              : "አንድ ችግር ተከስቷል — እባክዎ ከጥቂት ጊዜ በኋላ ደግሙ።",
        },
      ]);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Enter") handleSendMessage();
  };

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
            aria-label="Toggle Language"
          >
            <div className="h-5 w-5 text-[#0F3A31]">🌐</div>
          </button>
          <p className="text-black font-bold text-sm">
            {language === "en" ? "አማ" : "EN"}
          </p>
        </div>
      </header>

      {/* Chat Container */}
      <div className="relative max-w-3xl mx-auto px-4 pt-6 pb-28">
        {/* Page Title */}
        <header className="mb-4 pb-4 border-b border-gray-200">
          <h1 className="text-xl font-semibold">{t.freeformTitle}</h1>
          <p className="text-gray-500 text-sm">
            {t.sessionTypeLabel}: {sessionType}
          </p>
        </header>

        {/* Messages */}
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
          {isLoading && (
            <div className="flex justify-start">
              <div className="bg-blue-100 text-gray-800 p-3 rounded-xl max-w-xs md:max-w-md rounded-bl-none animate-pulse">
                {t.typing}
              </div>
            </div>
          )}
          <div ref={messagesEndRef} />
        </div>

        {/* Input Box */}
        <div className="fixed bottom-4 left-1/2 transform -translate-x-1/2 w-full max-w-3xl px-4">
          <div className="flex items-center bg-white border border-gray-300 rounded-lg shadow-lg p-2">
            <input
              type="text"
              className="flex-grow px-4 py-3 focus:outline-none"
              placeholder={t.placeholder}
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              onKeyDown={handleKeyDown}
              disabled={isLoading}
            />
            <button
              onClick={handleSendMessage}
              className="ml-2 p-3 rounded-lg bg-[#217C6A] text-white hover:bg-blue-700 transition-colors"
              disabled={isLoading}
              aria-label={language === "en" ? "Send message" : "መልእክት ላክ"}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-6 w-6 rotate-90"
                fill="currentColor"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default FreeformChatPage;
