"use client";

import React, { useState } from "react";
import { faClipboardList, faRobot } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { useRouter } from "next/navigation";
import {
  useGetFreeformUserChatsQuery,
  useGetStructuredUserChatsQuery,
} from "@/lib/redux/api/interviewApi";


interface InterviewHistoryItem {
  id: string;
  type: string;
  status?: string;
  updatedAt: string;
}

const translations = {
  en: {
    secondsAgo: (n: number) => `${n} seconds ago`,
    minutesAgo: (n: number) => `${n} minutes ago`,
    hoursAgo: (n: number) => `${n} hours ago`,
    daysAgo: (n: number) => (n === 1 ? "1 day ago" : `${n} days ago`),
    inProgress: "In Progress",
    completed: "Completed",
    continue: "Continue",
    view: "View",
    jobMate: "JobMate",
    tagline: "Your AI Career Buddy",
    interviewPractice: "Interview Practice",
    improveSkills: "Improve your interview skills with AI-powered coaching.",
    freeformInterview: "Freeform Interview",
    freeformDescription: "Interview-related practice chat with AI coach",
    startSession: "Start Session",
    structuredInterview: "Structured Interview",
    structuredDescription: "Field-specific Q&A with feedback",
    startInterview: "Start Interview",
    structuredHistory: "Structured Interview History",
    freeformHistory: "Freeform Interview History",
    noStructured: "No structured interviews yet.",
    noFreeform: "No freeform interviews yet.",
    viewAll: "View All",
  },
  am: {
    secondsAgo: (n: number) => `${n} ሰከንድ በፊት`,
    minutesAgo: (n: number) => `${n} ደቂቃ በፊት`,
    hoursAgo: (n: number) => `${n} ሰዓታት በፊት`,
    daysAgo: (n: number) => (n === 1 ? "1 ቀን በፊት" : `${n} ቀናት በፊት`),
    inProgress: "በሂደት ላይ",
    completed: "ተጠናቀቀ",
    continue: "ቀጥል",
    view: "እይታ",
    jobMate: "JobMate",
    tagline: "Your AI Career Buddy",
    interviewPractice: "የቃለ መጠይቅ ልምምድ",
    improveSkills: "ከAI አስተማማኝ እርዳታ ጋር የቃለ መጠይቅ ችሎታዎን ያሻሽሉ።",
    freeformInterview: "Freeform Interview",
    freeformDescription: "ከAI ጋር የቃለ መጠይቅ ውይይት",
    startSession: "ጀምር",
    structuredInterview: "Structured Interview",
    structuredDescription: "ልዩ ጥያቄዎች ከገንቢ አስተያየት ጋር",
    startInterview: "ቃለ መጠይቅ ጀምር",
    structuredHistory: "Structured Interview History",
    freeformHistory: "Freeform Interview",
    noStructured: "ምንም የለም።",
    noFreeform: "ምንም የለም።",
    viewAll: "ሁሉንም እይ",
  },
};

const formatTimeAgo = (timestamp: string, lang: "en" | "am"): string => {
  const updatedDate = new Date(timestamp);
  const now = new Date();
  const secondsAgo = Math.floor((now.getTime() - updatedDate.getTime()) / 1000);

  if (secondsAgo < 60) return translations[lang].secondsAgo(secondsAgo);
  const minutesAgo = Math.floor(secondsAgo / 60);
  if (minutesAgo < 60) return translations[lang].minutesAgo(minutesAgo);
  const hoursAgo = Math.floor(minutesAgo / 60);
  if (hoursAgo < 24) return translations[lang].hoursAgo(hoursAgo);
  const daysAgo = Math.floor(hoursAgo / 24);
  return translations[lang].daysAgo(daysAgo);
};

const HistoryItem: React.FC<{
  type: string;
  status?: string;
  updatedAt: string;
  onAction: () => void;
  language: "en" | "am";
}> = ({ type, status, updatedAt, onAction, language }) => {
  const statusMap = {
    "In Progress": translations[language].inProgress,
    Completed: translations[language].completed,
  };

  return (
    <div className="flex justify-between items-center py-4 border-b border-gray-200 last:border-b-0">
      <div>
        <div className="flex items-center gap-2">
          <span className="font-medium">{type}</span>
          {status && (
            <span
              className={`px-2 py-1 text-xs font-semibold rounded-full ${
                status === "In Progress"
                  ? "bg-amber-100 text-amber-800"
                  : "bg-green-100 text-green-800"
              }`}
            >
              {statusMap[status as keyof typeof statusMap] ?? status}
            </span>
          )}
        </div>
        <p className="text-sm text-gray-500">
          {formatTimeAgo(updatedAt, language)}
        </p>
      </div>
      <button
        onClick={onAction}
        className="text-[#217C6A] font-semibold hover:underline"
      >
        {status === "In Progress"
          ? translations[language].continue
          : translations[language].view}
      </button>
    </div>
  );
};

const InterviewPage: React.FC = () => {
  const [language, setLanguage] = useState<"en" | "am">("en");
  const router = useRouter();

  const { data: structuredData, isLoading: loadingStructured } =
    useGetStructuredUserChatsQuery();
    const s_data=structuredData;
  const { data: freeformData, isLoading: loadingFreeform } =
    useGetFreeformUserChatsQuery();
console.log("s_data:",s_data);
console.log("f_data:", freeformData);

  const structuredHistory: InterviewHistoryItem[] =
    structuredData?.data?.chats
      ?.map((chat: any) => ({
        id: chat.chat_id,
        type: chat.field,
        status: chat.is_completed ? "Completed" : "In Progress",
        updatedAt: chat.updated_at,
      }))
      .sort(
        (a: InterviewHistoryItem, b: InterviewHistoryItem) =>
          new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime()
      )
      .slice(0, 2) || [];

  const freeformHistory: InterviewHistoryItem[] =
    freeformData?.data
      ?.chats?.map((chat: any) => ({
        id: chat.chat_id,
        type: chat.session_type,
        updatedAt: chat.updated_at,
      }))
      .sort(
        (a: InterviewHistoryItem, b: InterviewHistoryItem) =>
          new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime()
      )
      .slice(0, 2) || [];

  return (
    <div className="min-h-screen bg-gray-50 font-sans text-gray-800">
      {/* Header */}
      <header className="flex items-center justify-between h-[80px] shadow px-4 bg-[#217C6A] text-white">
        <div className="flex items-center gap-3">
          <div className="h-5 w-5 text-white cursor-pointer">←</div>
          <div className="h-10 w-10 bg-[#0F3A31] text-white rounded-full flex items-center justify-center font-bold">
            JM
          </div>
          <div>
            <span className="font-semibold text-lg block">
              {translations[language].jobMate}
            </span>
            <span className="text-sm text-white/70">
              {translations[language].tagline}
            </span>
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

      <div className="bg-white min-h-screen">
        <nav className="bg-white p-4 flex justify-between items-center">
          <span className="text-xl font-bold text-transparent">
            {translations[language].interviewPractice}
          </span>
        </nav>

        <main className="container mx-auto px-4 py-8">
          <header className="text-center mb-10">
            <h1 className="text-3xl font-bold mb-2">
              {translations[language].interviewPractice}
            </h1>
            <p className="text-gray-500">
              {translations[language].improveSkills}
            </p>
          </header>

          {/* Interview type cards */}
          <section className="grid md:grid-cols-2 gap-6 mb-10">
            <div className="bg-white rounded-xl shadow-md p-6 border border-gray-200 text-center">
              <div className="flex justify-center items-center mb-4 bg-[#217C6A] rounded-full w-16 h-16 mx-auto">
                <FontAwesomeIcon
                  icon={faRobot}
                  className="text-white text-5xl mx-auto"
                />
              </div>
              <h2 className="text-xl font-semibold mb-2">
                {translations[language].freeformInterview}
              </h2>
              <p className="text-gray-500 mb-6 text-sm">
                {translations[language].freeformDescription}
              </p>
              <button
                onClick={() => router.push("/interview/freefrom/session")}
                className="bg-[#217C6A] text-white font-semibold py-3 px-6 rounded-full w-full hover:bg-[#4ade80] transition-colors"
              >
                {translations[language].startSession}
              </button>
            </div>

            <div className="bg-white rounded-xl shadow-md p-6 border border-gray-200 text-center">
              <div className="flex justify-center items-center mb-4 bg-[#217C6A] rounded-full w-16 h-16 mx-auto">
                <FontAwesomeIcon
                  icon={faClipboardList}
                  className="text-white text-2xl"
                />
              </div>
              <h2 className="text-xl font-semibold mb-2">
                {translations[language].structuredInterview}
              </h2>
              <p className="text-gray-500 mb-6 text-sm">
                {translations[language].structuredDescription}
              </p>
              <button
                onClick={() => router.push("/interview/structured/field")}
                className="bg-[#217C6A] text-white font-semibold py-3 px-6 rounded-full w-full hover:bg-green-400 transition-colors"
              >
                {translations[language].startInterview}
              </button>
            </div>
          </section>

          {/* History: Structured */}
          <section className="bg-white rounded-xl shadow-md p-6 border border-gray-200 mb-6">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-semibold flex items-center gap-2 text-[#217C6A]">
                <FontAwesomeIcon icon={faClipboardList} />
                {translations[language].structuredHistory}
              </h2>
              <button
                className="text-[#217C6A] font-semibold text-sm hover:underline"
                onClick={() => router.push("/interview/structured/history/all")}
              >
                {translations[language].viewAll}
              </button>
            </div>

            {loadingStructured ? (
              <p>{language === "en" ? "Loading..." : "በመጫን ላይ..."}</p>
            ) : (
              <div className="divide-y divide-gray-200">
                {structuredHistory.length === 0 ? (
                  <p className="text-gray-400 text-center py-4">
                    {translations[language].noStructured}
                  </p>
                ) : (
                  structuredHistory.map((item) => (
                    <HistoryItem
                      key={item.id}
                      type={item.type}
                      status={item.status}
                      updatedAt={item.updatedAt}
                      onAction={() => {
                        if (item.status === "In Progress") {
                          // Navigate to resume page when in progress
                          router.push(
                            `/interview/structured/resume?chatid=${item.id}`
                          );
                        } else {
                    
                          router.push(
                            `/interview/structured/history/?chatid=${item.id}`
                          );
                        }
                      }}
                      language={language}
                    />
                  ))
                )}
              </div>
            )}
          </section>

          {/* History: Freeform */}
          <section className="bg-white rounded-xl shadow-md p-6 border border-gray-200">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-semibold flex items-center gap-2 text-[#217C6A]">
                <FontAwesomeIcon icon={faRobot} />
                {translations[language].freeformHistory}
              </h2>
              <button
                className="text-[#217C6A] font-semibold text-sm hover:underline"
                onClick={() => router.push("/interview/freefrom/History/all")}
              >
                {translations[language].viewAll}
              </button>
            </div>

            {loadingFreeform ? (
              <p>{language === "en" ? "Loading..." : "በመጫን ላይ..."}</p>
            ) : (
              <div className="divide-y divide-gray-200">
                {freeformHistory.length === 0 ? (
                  <p className="text-gray-400 text-center py-4">
                    {translations[language].noFreeform}
                  </p>
                ) : (
                  freeformHistory.map((item) => (
                    <HistoryItem
                      key={item.id}
                      type={item.type}
                      updatedAt={item.updatedAt}
                      onAction={() =>
                        router.push(
                          `/interview/freefrom/History/?chatid=${item.id}`
                        )
                      }
                      language={language}
                    />
                  ))
                )}
              </div>
            )}
          </section>
        </main>
      </div>
    </div>
  );
};

export default InterviewPage;
