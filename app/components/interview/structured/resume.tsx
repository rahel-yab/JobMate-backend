"use client";

import React, { useState, useEffect } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import {
  useLazyResumeStructuredInterviewQuery,
  useAnswerStructuredQuestionMutation,
} from "@/lib/redux/api/interviewApi";

const texts = {
  en: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    interviewQuestion: "Interview Question",
    yourAnswer: "Your Answer",
    startTyping: "Start typing your answer here...",
    processing: "Processing...",
    finishInterview: "Interview Completed",
    submitAnswer: "Submit Answer",
    feedback: "Feedback",
    questionOf: "Question",
    of: "of",
    complete: "complete",
    unableResume: "Unable to resume interview. Please try again.",
    failedSubmit: "Failed to submit answer.",
    loadingQuestions: "Loading questions...",
    backToDashboard: "Back to Dashboard",
  },
  am: {
    jobMate: "JobMate",
    slogan: "Your AI Career Buddy",
    interviewQuestion: "የቃለ ምልልስ ጥያቄ",
    yourAnswer: "መልስዎ",
    startTyping: "እዚህ መልስዎን ይጻፉ...",
    processing: "በሂደት ላይ...",
    finishInterview: "ቃለ ምልልስ ተጠናቋል",
    submitAnswer: "መልስ አስገባ",
    feedback: "አስተያየት",
    questionOf: "ጥያቄ",
    of: "ከ",
    complete: "ተጠናቋል",
    unableResume: "ቃለ ምልልስ መቀጠል አልተቻለም። እባክዎ እንደገና ይሞክሩ።",
    failedSubmit: "መልስ ማስገባት አልተቻለም።",
    loadingQuestions: "ጥያቄዎች በመጫን ላይ...",
    backToDashboard: "ወደ ዳሽቦርድ ተመለስ",
  },
};

const ResumeInterview: React.FC = () => {
  const [language, setLanguage] = useState<"en" | "am">("en");
  const [userAnswer, setUserAnswer] = useState("");
  const [feedback, setFeedback] = useState("");
  const [errorMessage, setErrorMessage] = useState("");
  const [isProcessing, setIsProcessing] = useState(false);

  const router = useRouter();
  const searchParams = useSearchParams();
  const chatid = searchParams.get("chatid");

  const t = texts[language];

  const [triggerResumeInterview, { isFetching: resumeLoading }] =
    useLazyResumeStructuredInterviewQuery();

  const [answerStructuredQuestion, { isLoading: answering }] =
    useAnswerStructuredQuestionMutation();

  // Interview state
  const [chatId, setChatId] = useState("");
  const [question, setQuestion] = useState("");
  const [questionNumber, setQuestionNumber] = useState(1);
  const [totalQuestions, setTotalQuestions] = useState(1);
  const [isCompleted, setIsCompleted] = useState(false);

  // Automatically fetch questions on mount
  useEffect(() => {
    const fetchQuestions = async () => {
      if (!chatid) {
        setErrorMessage(t.unableResume);
        return;
      }
      try {
        const res = await triggerResumeInterview({ chat_id: chatid }).unwrap();
        if (res) {
          setChatId(res.chat_id);
          setQuestion(res.next_question ?? "");
          setQuestionNumber(
            typeof res.current_question === "number"
              ? res.current_question + 1
              : 1
          );
          setTotalQuestions(res.total_questions ?? 1);
          setIsCompleted(Boolean(res.is_completed));
        } else {
          setErrorMessage(t.unableResume);
        }
      } catch (err) {
        console.error("Failed to resume interview:", err);
        setErrorMessage(t.unableResume);
      }
    };

    fetchQuestions();
  }, [chatid, triggerResumeInterview, t.unableResume]);

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
      const cleanedFeedback = data.feedback?.includes(nextQuestionMarker)
        ? data.feedback.split(nextQuestionMarker)[0].trim()
        : data.feedback;

      setFeedback(cleanedFeedback || "");
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
      {!resumeLoading && question && !isCompleted && (
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
      )}

      {/* Main content */}
      <main className="container mx-auto max-w-4xl space-y-6">
        {errorMessage && (
          <div className="bg-red-100 text-red-700 p-4 rounded-lg border border-red-300">
            {errorMessage}
          </div>
        )}

        {resumeLoading ? (
          <div className="text-center text-gray-600 p-6">
            {t.loadingQuestions}
          </div>
        ) : isCompleted ? (
          <div className="bg-white rounded-xl shadow-md p-6 border border-gray-200 text-center">
            <h2 className="text-xl font-semibold mb-4 text-green-700">
              {t.finishInterview}
            </h2>

            {feedback ? (
              <>
                <h3 className="text-lg font-semibold text-green-700 mb-2">
                  {t.feedback}
                </h3>
                <pre className="whitespace-pre-wrap text-green-800 mb-4">
                  {feedback}
                </pre>
              </>
            ) : (
              <p className="text-gray-700">{t.complete} ✅</p>
            )}
          </div>
        ) : (
          <>
            <div className="bg-white rounded-xl shadow-md p-6 border border-gray-200">
              <h2 className="text-xl font-semibold mb-4">
                {t.interviewQuestion}
              </h2>
              <p className="text-gray-700">{question}</p>
            </div>

            <div className="bg-white rounded-xl shadow-md p-6 border border-gray-200">
              <h2 className="text-xl font-semibold mb-4">{t.yourAnswer}</h2>
              <textarea
                className="w-full p-4 border border-gray-300 rounded-lg text-gray-700 focus:outline-none focus:ring-2 focus:ring-[#217C6A] h-48"
                value={userAnswer}
                onChange={(e) => setUserAnswer(e.target.value)}
                placeholder={t.startTyping}
                disabled={isProcessing || answering}
              />
              <button
                onClick={handleSubmit}
                disabled={isProcessing || answering || !userAnswer.trim()}
                className={`w-full mt-4 py-3 px-6 rounded-lg text-white font-semibold transition-colors ${
                  isProcessing || answering
                    ? "bg-[#217C6A] cursor-not-allowed"
                    : "bg-[#217C6A] hover:bg-blue-700"
                }`}
              >
                {isProcessing || answering
                  ? t.processing
                  : questionNumber === totalQuestions
                  ? t.finishInterview
                  : t.submitAnswer}
              </button>
            </div>

            {feedback && (
              <div className="bg-green-50 rounded-xl shadow-md p-6 border border-green-200 transition-opacity duration-500">
                <h2 className="text-xl font-semibold text-green-700 mb-4">
                  {t.feedback}
                </h2>
                <pre className="whitespace-pre-wrap text-green-800">
                  {feedback}
                </pre>
              </div>
            )}
          </>
        )}
      </main>
    </div>
  );
};

export default ResumeInterview;
