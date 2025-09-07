"use client";

import React, { useState, useEffect } from "react";
import { useRef } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import {
  useStartStructuredInterviewMutation,
  useAnswerStructuredQuestionMutation,
} from "@/lib/redux/api/interviewApi"; // Adjust path

const texts = {
  en: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    interviewQuestion: "Interview Question",
    yourAnswer: "Your Answer",
    startTyping: "Start typing your answer here...",
    processing: "Processing...",
    finishInterview: "Finish Interview",
    submitAnswer: "Submit Answer",
    feedback: "Feedback",
    questionOf: "Question",
    of: "of",
    complete: "complete",
    unableStart: "Unable to start interview. Please try again.",
    failedSubmit: "Failed to submit answer.",
  },
  am: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    interviewQuestion: "የቃለ ምልልስ ጥያቄ",
    yourAnswer: "መልስዎ",
    startTyping: "እዚህ መልስዎን ይጻፉ...",
    processing: "በሂደት ላይ...",
    finishInterview: "ቃለ መጠይቅ ያጠናቁ",
    submitAnswer: "መልስ አስገባ",
    feedback: "አስተያየት",
    questionOf: "ጥያቄ",
    of: "ከ",
    complete: "ተጠናቋል",
    unableStart:
      "ቃለ ምልልስ ማስጀመር አልተቻለም። እባክዎ እንደገና ይሞክሩ።",
    failedSubmit: "መልስ ማስገባት አልተቻለም።",
  },
};

const StructuredQuestion: React.FC = () => {
  const [questionNumber, setQuestionNumber] = useState(1);
  const [totalQuestions, setTotalQuestions] = useState(1);
  const [userAnswer, setUserAnswer] = useState("");
  const [feedback, setFeedback] = useState("");
  const [isProcessing, setIsProcessing] = useState(false);
  const [question, setQuestion] = useState("");
  const [language, setLanguage] = useState<"en" | "am">("en");
  const [chatId, setChatId] = useState("");
  const [isCompleted, setIsCompleted] = useState(false);
  const [errorMessage, setErrorMessage] = useState("");

  const router = useRouter();
  const searchParams = useSearchParams();
  const field = searchParams.get("field");

  const t = texts[language];



  // RTK Query mutation hooks
  const [startStructuredInterview, { isLoading: starting }] =
    useStartStructuredInterviewMutation();
  const [answerStructuredQuestion, { isLoading: answering }] =
    useAnswerStructuredQuestionMutation();

 const hasStartedRef = useRef(false); // ✅ Used to prevent duplicate calls

useEffect(() => {
  if (!field || hasStartedRef.current) return;

  hasStartedRef.current = true; // ✅ Mark as started *before* API call

  const init = async () => {
    try {
      const res = await startStructuredInterview({
        field,
        preferred_language: language,
      }).unwrap();

      const data = res.data;

      setChatId(data.chat_id);
      setTotalQuestions(data.total_questions);
      setQuestion(data.first_question);
      setQuestionNumber(1);
      setIsCompleted(false);
      setErrorMessage("");
    } catch (error) {
      console.error("Failed to start structured interview:", error);
      setErrorMessage(t.unableStart);
      hasStartedRef.current = false; // ✅ Reset if failed
    }
  };

  init();
}, [field, startStructuredInterview, t.unableStart]);


  const handleSubmit = async () => {
    if (!chatId || !userAnswer.trim()) return;

    setIsProcessing(true);
    setFeedback("");
    setErrorMessage("");

    try {
      const res = await answerStructuredQuestion({
        chat_id: chatId,
        answer: userAnswer,
      }).unwrap();

      const data = res.data;
      const nextQuestionMarker = "Next Question";
      const cleanedFeedback = data.feedback.includes(nextQuestionMarker)
        ? data.feedback.split(nextQuestionMarker)[0].trim()
        : data.feedback;

      setFeedback(cleanedFeedback);
      setTotalQuestions(data.total_questions);

      if (data.is_completed) {
        setIsCompleted(true);
      } else {
        setQuestion(data.next_question);
        setQuestionNumber(data.question_index + 1);
      }

      setUserAnswer("");
    } catch (error) {
      console.error("Error submitting answer:", error);
      setErrorMessage(t.failedSubmit);
    } finally {
      setIsProcessing(false);
    }
  };

  const progressPercentage = Math.min(
    (questionNumber / totalQuestions) * 100,
    100
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

      {/* Progress bar */}
      <div className="max-w-4xl mx-auto mt-6 mb-6">
        <div className="flex items-center justify-between">
          <span className="text-gray-500 text-sm">
            {t.questionOf} {Math.min(questionNumber, totalQuestions)} {t.of}{" "}
            {totalQuestions}
          </span>
          <span className="text-gray-500 text-sm">
            {Math.round(progressPercentage)}% {t.complete}
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
        {/* Error message */}
        {errorMessage && (
          <div className="bg-red-100 text-red-700 p-4 rounded-lg border border-red-300">
            {errorMessage}
          </div>
        )}

        {/* Interview Question */}
        <div className="bg-white rounded-xl shadow-md p-6 border border-gray-200">
          <h2 className="text-xl font-semibold mb-4">{t.interviewQuestion}</h2>
          <p className="text-gray-700">{question}</p>
        </div>

        {/* Answer Box */}
        {!isCompleted && (
          <div className="bg-white rounded-xl shadow-md p-6 border border-gray-200">
            <h2 className="text-xl font-semibold mb-4">{t.yourAnswer}</h2>
            <div className="relative">
              <textarea
                className="w-full p-4 border border-gray-300 rounded-lg text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#217C6A] h-48"
                value={userAnswer}
                onChange={(e) => setUserAnswer(e.target.value)}
                placeholder={t.startTyping}
                disabled={isProcessing || starting || answering}
              />
            </div>
            <button
              onClick={handleSubmit}
              className={`w-full mt-4 py-3 px-6 rounded-lg text-white font-semibold transition-colors ${
                isProcessing || starting || answering
                  ? "bg-[#217C6A] cursor-not-allowed"
                  : "bg-[#217C6A] hover:bg-blue-700"
              }`}
              disabled={isProcessing || starting || answering}
            >
              {isProcessing || starting || answering
                ? t.processing
                : questionNumber === totalQuestions
                ? t.finishInterview
                : t.submitAnswer}
            </button>
          </div>
        )}

        {/* Feedback */}
        {feedback && (
          <div className="bg-green-50 rounded-xl shadow-md p-6 border border-green-200 transition-opacity duration-500">
            <h2 className="text-xl font-semibold text-green-700 mb-4">
              {t.feedback}
            </h2>
            <pre className="whitespace-pre-wrap text-green-800">{feedback}</pre>
          </div>
        )}
      </main>
    </div>
  );
};

export default StructuredQuestion;
