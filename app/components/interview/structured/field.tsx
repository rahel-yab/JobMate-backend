"use client";
import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { faClipboardList } from "@fortawesome/free-solid-svg-icons";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";

const texts = {
  en: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    structuredInterview: "Structured Interview",
    description: "Get field-specific questions with detailed feedback",
    enterField: "Enter Your Field",
    placeholder: "e.g. Software Engineering, Marketing, ...",
    startInterview: "Start Interview",
    alertFieldRequired: "Please enter a field.",
  },
  am: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    structuredInterview: "Structured Interview",
    description: "ልዩ ጥያቄዎች ከገንቢ አስተያየት ጋር",
    enterField: "መስክዎን(የ ስራ ዘርፍ) ያስገቡ",
    placeholder: "ለምሳሌ፡ ሶፍትዌር ኢንጅነሪንግ፣ ማርኬቲንግ፣ ...",
    startInterview: "ቃለ ምልልስ ጀምር",
    alertFieldRequired: "እባክዎ መስክ ያስገቡ።",
  },
};

const FiledApp: React.FC = () => {
  const [language, setLanguage] = useState<"en" | "am">("en");
  const [sessionType, setSessionType] = useState("");
  const [error, setError] = useState("");
  const router = useRouter();

  const t = texts[language];

  const handleStartInterview = () => {
    if (!sessionType.trim()) {
      setError(t.alertFieldRequired);
      return;
    }

    setError(""); // Clear error if any
    router.push(
      `/interview/structured?field=${encodeURIComponent(sessionType.trim())}`
    );
  };

  return (
    <div className="bg-gradient-to-b from-green-50 to-blue-50 min-h-screen  flex flex-col bg-gray-50 font-sans text-gray-800">
      {/* Header */}
      <header className="flex items-center justify-between h-[80px] shadow px-4 bg-[#E6FFFA] text-black">
        <div className="flex items-center gap-3">
          <div
            className="h-5 w-5 text-black cursor-pointer"
            onClick={() => router.push("/interview")}
          >
            ←
          </div>
          <div className="h-10 w-10 bg-[#0F3A31] text-white rounded-full flex items-center justify-center font-bold">
            JM
          </div>
          <div>
            <span className="font-semibold text-lg block">{t.jobMate}</span>
            <span className="text-sm text-black/70">{t.slogan}</span>
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

      <div className="bg-gradient-to-b from-green-50 to-blue-50 min-h-screen">
        {/* Main Card */}
        <div className="flex-grow flex items-center justify-center p-4">
          <div className="container mx-auto max-w-sm bg-white rounded-xl shadow-md p-6 border border-gray-200 text-center">
            <div className="flex justify-center items-center mb-4 bg-[#217C6A] rounded-full w-16 h-16 mx-auto">
              <FontAwesomeIcon
                icon={faClipboardList}
                className="text-white text-2xl"
              />
            </div>

            <h1 className="text-2xl font-semibold mb-2">
              {t.structuredInterview}
            </h1>
            <p className="text-gray-500 text-sm mb-6">{t.description}</p>

            <div className="relative mb-2 text-left">
              <p className="text-sm font-medium text-gray-600 mb-2">
                {t.enterField}
              </p>
              <input
                type="text"
                value={sessionType}
                onChange={(e) => {
                  setSessionType(e.target.value);
                  if (error) setError("");
                }}
                placeholder={t.placeholder}
                className={`w-full bg-white border ${
                  error ? "border-red-500" : "border-gray-300"
                } rounded-lg shadow-sm py-2 px-4 focus:outline-none focus:ring-2 ${
                  error ? "focus:ring-red-500" : "focus:ring-[#217C6A]"
                }`}
              />
              {error && <p className="text-red-600 text-sm mt-2">{error}</p>}
            </div>

            <button
              onClick={handleStartInterview}
              disabled={!sessionType.trim()}
              className={`w-full mt-4 py-3 rounded-lg text-white font-semibold transition-colors ${
                !sessionType.trim()
                  ? "bg-gray-300 cursor-not-allowed"
                  : "bg-[#217C6A] hover:bg-[#4ade80]"
              }`}
            >
              {t.startInterview}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default FiledApp;
