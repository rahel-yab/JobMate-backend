"use client";

import React, { useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faClipboardList } from "@fortawesome/free-solid-svg-icons";
import { useRouter } from "next/navigation";
import { useGetStructuredUserChatsQuery } from "@/lib/redux/api/interviewApi"; // RTK Query hook

interface StructuredChatItem {
  id: string;
  title: string;
  subtitle: string;
  status: "In Progress" | "Completed";
  updatedAt: string;
}

// ✅ Format time ago
const formatTimeAgo = (timestamp: string): string => {
  const updatedDate = new Date(timestamp);
  const now = new Date();
  const secondsAgo = Math.floor((now.getTime() - updatedDate.getTime()) / 1000);

  if (secondsAgo < 60) return `${secondsAgo} seconds ago`;
  const minutesAgo = Math.floor(secondsAgo / 60);
  if (minutesAgo < 60) return `${minutesAgo} minutes ago`;
  const hoursAgo = Math.floor(minutesAgo / 60);
  if (hoursAgo < 24) return `${hoursAgo} hours ago`;

  const daysAgo = Math.floor(hoursAgo / 24);
  return daysAgo === 1 ? "1 day ago" : `${daysAgo} days ago`;
};

const texts = {
  en: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    historyTitle: "Structured Interview History",
    historyDesc:
      "Review your structured interview practice sessions with specific field questions.",
    loading: "Loading...",
    noHistory: "No interview history found.",
    lastActivity: "Last activity",
    continue: "Continue",
    viewDetails: "View Details",
    completed: "Completed",
    inProgress: "In Progress",
  },
  am: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    historyTitle: "Structured Interview History",
    historyDesc: " ከዚህ በፊት የተልማዱትን ጥያቄዎችን ይመልከቱ።",
    loading: "በመጫን ላይ...",
    noHistory: "ምንም የቃለ መጠይቅ ታሪክ አልተገኘም።",
    lastActivity: "የመጨረሻ ታየበት",
    continue: "ቀጥል",
    viewDetails: "ዝርዝር ይመልከቱ",
    completed: "ተጠናቅቋል",
    inProgress: "በሂደት ላይ",
  },
};

const StructuredHistory: React.FC = () => {
  const [language, setLanguage] = useState<"en" | "am">("en");
  const router = useRouter();
  const t = texts[language];

  // ✅ RTK Query call
  const {
    data: chatHistory,
    isLoading,
    error,
  } = useGetStructuredUserChatsQuery();

  // ✅ Extract & sort history items
  const structuredHistory: StructuredChatItem[] =
    chatHistory?.data?.chats
      ?.map((chat: any) => ({
        id: chat.chat_id,
        title: chat.field,
        subtitle: chat.field,
        status: chat.is_completed ? "Completed" : "In Progress",
        updatedAt: chat.updated_at,
      }))
      ?.sort(
        (a: StructuredChatItem, b: StructuredChatItem) =>
          new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime()
      ) ?? [];

  const HistoryItem: React.FC<{ item: StructuredChatItem }> = ({ item }) => (
    <div className="flex flex-col md:flex-row justify-between items-start p-4 bg-white rounded-lg shadow-sm border border-gray-200 mb-4">
      <div className="flex-grow flex items-start w-full md:w-auto">
        <div className="flex flex-col flex-grow">
          <div className="flex justify-between items-start w-full">
            <div className="flex items-center gap-2">
              <FontAwesomeIcon
                icon={faClipboardList}
                className="h-5 w-5 text-[#217C6A]"
              />
              <h3 className="text-lg font-semibold text-gray-800">
                {item.title}
              </h3>
            </div>

            {item.status === "Completed" ? (
              <span className="flex items-center text-green-600 font-semibold text-sm">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="h-4 w-4 mr-1"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fillRule="evenodd"
                    d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                    clipRule="evenodd"
                  />
                </svg>
                {t.completed}
              </span>
            ) : (
              <span className="bg-amber-100 text-amber-800 text-xs font-semibold px-2 py-1 rounded-full">
                {t.inProgress}
              </span>
            )}
          </div>

          <p className="text-gray-500 text-sm">{item.subtitle}</p>
          <p className="text-gray-500 text-xs mt-2">
            {t.lastActivity}: {formatTimeAgo(item.updatedAt)}
          </p>

          <div className="flex justify-end mt-3">
            <button
              className="px-4 py-1.5 bg-white border border-blue-600 text-blue-600 text-sm font-medium rounded hover:bg-blue-50 transition-colors"
              onClick={() =>
                router.push(`/interview/structured/history/?chatid=${item.id}`)
              }
            >
              {item.status === "In Progress" ? t.continue : t.viewDetails}
            </button>
          </div>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-gradient-to-b from-green-50 to-blue-50 font-sans text-gray-800">
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

      <div className="px-4 mt-6">
        <header className="mb-8">
          <h1 className="text-2xl font-bold text-gray-800">{t.historyTitle}</h1>
          <p className="text-gray-500 mt-1">{t.historyDesc}</p>
        </header>

        <div className="space-y-4">
          {isLoading ? (
            <p className="text-center text-gray-400">{t.loading}</p>
          ) : structuredHistory.length === 0 ? (
            <p className="text-center text-gray-400">{t.noHistory}</p>
          ) : (
            structuredHistory.map((item) => (
              <HistoryItem key={item.id} item={item} />
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default StructuredHistory;
