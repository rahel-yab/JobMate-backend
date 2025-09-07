"use client";

import React, { useState } from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faRobot } from "@fortawesome/free-solid-svg-icons";
import { useRouter } from "next/navigation";
import { useGetFreeformUserChatsQuery } from "@/lib/redux/api/interviewApi";

interface FreeformChatItem {
  id: string;
  title: string;
  subtitle?: string;
  updatedAt: string;
}

const texts = {
  en: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    pageTitle: "Freeform Interview History",
    pageDescription: "Review your freeform interview practice sessions.",
    lastActivity: "Last activity",
    viewDetails: "View Details",
    loading: "Loading...",
    noHistory: "No interview history found.",
    secondsAgo: "seconds ago",
    minutesAgo: "minutes ago",
    hoursAgo: "hours ago",
    dayAgo: "1 day ago",
    daysAgo: "days ago",
  },
  am: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    pageTitle: "የቃለ መጠይቅ ታሪክ",
    pageDescription: "የቃለ መጠይቅ ልምምድዎን ይመልከቱ።",
    lastActivity: "መጨረሻ እንቅስቃሴ",
    viewDetails: "ዝርዝሩን ይመልከቱ",
    loading: "በመጫን ላይ...",
    noHistory: "ምንም የቃለ መጠይቅ ታሪክ አልተገኘም።",
    secondsAgo: "ሰከንዶች በፊት",
    minutesAgo: "ደቂቃዎች በፊት",
    hoursAgo: "ሰዓቶች በፊት",
    dayAgo: "አንድ ቀን በፊት",
    daysAgo: "ቀናት በፊት",
  },
};

const formatTimeAgo = (timestamp: string, lang: "en" | "am"): string => {
  const t = texts[lang];
  const updatedDate = new Date(timestamp);
  const now = new Date();
  const secondsAgo = Math.floor((now.getTime() - updatedDate.getTime()) / 1000);

  if (secondsAgo < 60) return `${secondsAgo} ${t.secondsAgo}`;
  const minutesAgo = Math.floor(secondsAgo / 60);
  if (minutesAgo < 60) return `${minutesAgo} ${t.minutesAgo}`;
  const hoursAgo = Math.floor(minutesAgo / 60);
  if (hoursAgo < 24) return `${hoursAgo} ${t.hoursAgo}`;
  const daysAgo = Math.floor(hoursAgo / 24);
  return daysAgo === 1 ? t.dayAgo : `${daysAgo} ${t.daysAgo}`;
};

const FreeformHistory: React.FC = () => {
  const [language, setLanguage] = useState<"en" | "am">("en");
  const router = useRouter();
  const t = texts[language];

  const { data, isLoading, error } = useGetFreeformUserChatsQuery();

  const freeformHistory: FreeformChatItem[] =
    data?.data?.chats
      ?.filter(
        (chat: any) =>
          chat.session_type === "General" ||
          chat.session_type === "Technical" ||
          chat.session_type === "Behavioral"
      )
      .map((chat: any) => ({
        id: chat.chat_id,
        title: chat.session_type,
        subtitle: chat.last_message || "",
        updatedAt: chat.updated_at,
      }))
      .sort(
        (a: any, b: any) =>
          new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime()
      ) || [];

  const HistoryItem: React.FC<{ item: FreeformChatItem }> = ({ item }) => (
    <div className="flex flex-col md:flex-row justify-between items-start p-4 bg-white rounded-lg shadow-sm border border-gray-200 mb-4">
      <div className="flex-grow flex items-start w-full md:w-auto">
        <div className="flex flex-col flex-grow">
          <div className="flex items-center gap-2 mb-1">
            <FontAwesomeIcon
              icon={faRobot}
              className="h-5 w-5 text-[#217C6A]"
            />
            <h3 className="text-lg font-semibold text-gray-800">
              {item.title}
            </h3>
          </div>

          <p className="text-gray-500 text-sm">{item.subtitle}</p>
          <p className="text-gray-500 text-xs mt-2">
            {t.lastActivity}: {formatTimeAgo(item.updatedAt, language)}
          </p>

          <div className="flex justify-end mt-3">
            <button
              className="px-4 py-1.5 bg-white border border-blue-600 text-blue-600 text-sm font-medium rounded hover:bg-blue-50 transition-colors"
              onClick={() =>
                router.push(`/interview/freefrom/History/?chatid=${item.id}`)
              }
            >
              {t.viewDetails}
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
          <h1 className="text-2xl font-bold text-gray-800">{t.pageTitle}</h1>
          <p className="text-gray-500 mt-1">{t.pageDescription}</p>
        </header>

        <div className="space-y-4">
          {isLoading ? (
            <p className="text-center text-gray-400">{t.loading}</p>
          ) : error ? (
            <p className="text-center text-red-500">Failed to load history.</p>
          ) : freeformHistory.length === 0 ? (
            <p className="text-center text-gray-400">{t.noHistory}</p>
          ) : (
            freeformHistory.map((item) => (
              <HistoryItem key={item.id} item={item} />
            ))
          )}
        </div>
      </div>
    </div>
  );
};

export default FreeformHistory;
