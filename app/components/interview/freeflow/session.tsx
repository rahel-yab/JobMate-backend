"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { faRobot } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

const texts = {
  en: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    freeformTitle: "Freeform Interview",
    freeformDesc: "Have an interview-focused conversation with your AI coach",
    sessionTypeLabel: "Session Type",
    startSession: "Start Session",
    alertChooseSession: "Please choose a Session.",
    sessionTypes: {
      General: "General",
      Technical: "Technical",
      Behavioral: "Behavioral",
    },
  },
  am: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    freeformTitle: "Freeform Interview",
    freeformDesc: "ከAI አስተማማኝ እርዳታ ጋር የቃለ መጠይቅ ችሎታዎን ያሻሽሉ።",
    sessionTypeLabel: "የክፍል ዓይነት",
    startSession: "ጀምር",
    alertChooseSession: "እባክዎ ክፍል ይምረጡ።",
    sessionTypes: {
      General: "አጠቃላይ",
      Technical: "ቴክኒካዊ",
      Behavioral: "የባህሪ",
    },
  },
};

// Add `as const` so TypeScript knows these are literal types
const sessionTypeKeys = ["General", "Technical", "Behavioral"] as const;
type SessionTypeKey = (typeof sessionTypeKeys)[number];

const FreeformSessionPage: React.FC = () => {
  const [sessionType, setSessionType] = useState<SessionTypeKey>("General");
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [language, setLanguage] = useState<"en" | "am">("en");
  const [error, setError] = useState(""); // <-- new error state
  const router = useRouter();

  const t = texts[language];

  const handleStartSession = () => {
    if (!sessionType.trim()) {
      setError(t.alertChooseSession); // show error instead of alert
      return;
    }
    setError(""); // clear error
    router.push(
      `/interview/freefrom/AIchat/?session=${encodeURIComponent(sessionType)}`
    );
  };

  return (
    <div className="bg-gray-50 font-sans text-gray-800 min-h-screen flex flex-col">
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

      {/* Main content */}
      <main className="flex-grow flex items-center justify-center p-4 sm:p-6 md:p-8">
        <div className="container mx-auto max-w-sm bg-white rounded-xl shadow-md p-6 border border-gray-200 text-center">
          {/* AI icon */}
          <div className="flex justify-center items-center mb-4 bg-[#217C6A] rounded-full w-16 h-16 mx-auto">
            <FontAwesomeIcon
              icon={faRobot}
              className="text-white text-5xl mx-auto"
            />
          </div>

          <h1 className="text-2xl font-semibold mb-2">{t.freeformTitle}</h1>
          <p className="text-gray-500 text-sm mb-6">{t.freeformDesc}</p>

          {/* Error message */}
          {error && (
            <div className="mb-4 text-red-600 font-semibold">{error}</div>
          )}

          {/* Session Type Dropdown */}
          <div className="relative mb-6">
            <p className="text-sm font-medium text-gray-600 mb-2">
              {t.sessionTypeLabel}
            </p>
            <button
              onClick={() => setIsDropdownOpen(!isDropdownOpen)}
              className="w-full text-left bg-white border border-gray-300 rounded-lg shadow-sm py-2 px-4 flex items-center justify-between focus:outline-none focus:ring-2 focus:ring-[#217C6A]"
            >
              <span>{t.sessionTypes[sessionType]}</span>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className={`h-5 w-5 text-gray-400 transform transition-transform duration-200 ${
                  isDropdownOpen ? "rotate-180" : "rotate-0"
                }`}
                viewBox="0 0 20 20"
                fill="currentColor"
              >
                <path
                  fillRule="evenodd"
                  d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z"
                  clipRule="evenodd"
                />
              </svg>
            </button>
            {isDropdownOpen && (
              <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-lg shadow-lg">
                {sessionTypeKeys.map((type) => (
                  <div
                    key={type}
                    className="p-3 text-left hover:bg-gray-100 cursor-pointer flex justify-between items-center"
                    onClick={() => {
                      setSessionType(type);
                      setIsDropdownOpen(false);
                      setError(""); // clear error on valid selection
                    }}
                  >
                    {t.sessionTypes[type]}
                    {sessionType === type && (
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        className="h-5 w-5 text-[#217C6A]"
                        viewBox="0 0 20 20"
                        fill="currentColor"
                      >
                        <path
                          fillRule="evenodd"
                          d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                          clipRule="evenodd"
                        />
                      </svg>
                    )}
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Start button */}
          <button
            onClick={handleStartSession}
            className="w-full py-3 rounded-lg text-white font-semibold bg-[#217C6A] hover:bg-[#4ade80] transition-colors"
          >
            {t.startSession}
          </button>
        </div>
      </main>
    </div>
  );
};

export default FreeformSessionPage;
