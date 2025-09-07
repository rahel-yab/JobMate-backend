"use client";

import React, { useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { useGetStructuredHistoryQuery } from "@/lib/redux/api/interviewApi";

const texts = {
  en: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    loading: "Loading interview history...",
    question: "Question",
    yourAnswer: "Your Answer:",
    feedback: "Feedback:",
    previous: "Previous",
    next: "Next",
    completion:
      "You have successfully reviewed all your responses and feedback.",
    alert: "Unable to load interview history.",
  },
  am: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    loading: "የቃለ መጠይቅ ታሪክ በመጫን ላይ...",
    question: "ጥያቄ",
    yourAnswer: "መልስዎ:",
    feedback: "አስተያየት:",
    previous: "ወደ ኋላ",
    next: "ወደ ፊት",
    completion: "ሁሉንም ምላሾችዎን እና አስተያየቶችን በትክክል አጠናቀዋል።",
    alert: "የቃለ መጠይቅ ታሪክን መጫን አልተቻለም።",
  },
};

const StructuredsingleHistory: React.FC = () => {
  const [language, setLanguage] = useState<"en" | "am">("en");
  const [currentIndex, setCurrentIndex] = useState(0);

  const router = useRouter();
  const searchParams = useSearchParams();
  const chatId = searchParams.get("chatid");

  const t = texts[language];

  const {
    data: chatHistory,
    error,
    isLoading,
  } = useGetStructuredHistoryQuery(chatId!, {
    skip: !chatId,
  });
console.log("ddd:",chatHistory);
  const structuredQA =
    chatHistory?.data?.questions?.map((question: string, index: number) => {
      const userMessage = chatHistory.data.messages.find(
        (m: any) => m.role === "user" && m.question_index === index
      );
      const assistantMessage = chatHistory.data.messages.find(
        (m: any) => m.role === "assistant" && m.question_index === index
      );

      return {
        index: index + 1,
        question,
        userAnswer: userMessage?.content || "No answer provided.",
        feedback: assistantMessage?.content || "No feedback available.",
      };
    }) || [];

  const currentQA = structuredQA[currentIndex] || {};

  const handlePrevious = () => {
    if (currentIndex > 0) {
      setCurrentIndex(currentIndex - 1);
    }
  };

  const handleNext = () => {
    if (currentIndex < structuredQA.length - 1) {
      setCurrentIndex(currentIndex + 1);
    }
  };

  const progressPercentage = Math.round(
    ((currentIndex + 1) / structuredQA.length) * 100
  );

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p className="text-gray-600 text-lg">{t.loading}</p>
      </div>
    );
  }

  if (error || !chatHistory) {
    return (
      <div className="min-h-screen flex items-center justify-center p-4">
        <div className="bg-red-100 text-red-700 border border-red-300 p-4 rounded-lg text-center max-w-4xl mx-auto">
          {t.alert}
        </div>
      </div>
    );
  }

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
          >
            <div className="h-5 w-5 text-[#0F3A31]">🌐</div>
          </button>
          <p className="text-black font-bold text-sm">
            {language === "en" ? "አማ" : "EN"}
          </p>
        </div>
      </header>

      {/* Progress */}
      <div className="max-w-4xl mx-auto mt-6 mb-6">
        <div className="flex items-center justify-between">
          <span className="text-gray-500 text-sm">
            {t.question} {currentIndex + 1} of {structuredQA.length}
          </span>
          <span className="text-gray-500 text-sm">
            {progressPercentage}% complete
          </span>
        </div>
        <div className="mt-2 w-full bg-gray-200 rounded-full h-2.5">
          <div
            className="bg-[#217C6A] h-2.5 rounded-full"
            style={{ width: `${progressPercentage}%` }}
          ></div>
        </div>
      </div>

      {/* Main content */}
      <main className="container mx-auto max-w-4xl space-y-6">
        <div className="bg-white rounded-xl shadow-md p-6 border border-gray-200 space-y-4">
          <h2 className="text-xl font-semibold text-[#217C6A]">
            {t.question} {currentQA.index}
          </h2>
          <p className="text-gray-800">{currentQA.question}</p>

          <div>
            <h3 className="mt-4 font-semibold text-gray-700">{t.yourAnswer}</h3>
            <p className="text-gray-800 whitespace-pre-wrap">
              {currentQA.userAnswer}
            </p>
          </div>

          <div>
            <h3 className="mt-4 font-semibold text-green-700">{t.feedback}</h3>
            <p className="text-green-800 whitespace-pre-wrap">
              {currentQA.feedback}
            </p>
          </div>
        </div>

        {/* Navigation buttons */}
        <div className="flex justify-between mt-6">
          <button
            onClick={handlePrevious}
            disabled={currentIndex === 0}
            className={`px-6 py-3 rounded-lg font-semibold ${
              currentIndex === 0
                ? "bg-gray-300 text-gray-600 cursor-not-allowed"
                : "bg-[#217C6A] text-white hover:bg-[#1b6b5c]"
            }`}
          >
            {t.previous}
          </button>
          <button
            onClick={handleNext}
            disabled={currentIndex === structuredQA.length - 1}
            className={`px-6 py-3 rounded-lg font-semibold ${
              currentIndex === structuredQA.length - 1
                ? "bg-gray-300 text-gray-600 cursor-not-allowed"
                : "bg-[#217C6A] text-white hover:bg-[#1b6b5c]"
            }`}
          >
            {t.next}
          </button>
        </div>

        {chatHistory?.is_completed &&
          currentIndex === structuredQA.length - 1 && (
            <div className="text-center mt-10">
              <p className="text-gray-600 mt-2">{t.completion}</p>
            </div>
          )}
      </main>
    </div>
  );
};

export default StructuredsingleHistory;
