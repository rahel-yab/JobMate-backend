"use client";
import { useState, useEffect } from "react";
import { ArrowLeft, Globe, Send } from "lucide-react";
import ChatMessage from "./ChatMessage";
import { useLanguage } from "@/context/language-provider";
import QuickActions from "./QuickActions";
import { CVProgressive } from "../cv/CVProgressive";
import toast from "react-hot-toast";
import {
  useUploadCVMutation,
  useAnalyzeCVMutation,
} from "@/lib/redux/api/cvApi";

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
  const [mode, setMode] = useState<
    "cv" | "jobs" | "interview" | "skills" | "chat"
  >("chat");

  const [uploadCV] = useUploadCVMutation();
  const [analyzeCV] = useAnalyzeCVMutation();

  const sendMessage = async () => {
    if (!input.trim()) return;

    const newMsg = {
      id: Date.now(),
      text: input,
      sender: "user",
      time: formatTime(),
    };
    setMessages((prev) => [...prev, newMsg]);

    let currentMode = mode;
    const lowerInput = input.toLowerCase();

    if (currentMode === "chat") {
      if (lowerInput.includes("cv")) currentMode = "cv";
      else if (lowerInput.includes("job")) currentMode = "jobs";
      else if (lowerInput.includes("interview")) currentMode = "interview";
      else if (lowerInput.includes("skill")) currentMode = "skills";
    }
    setMode(currentMode);
    let aiResponse = "";

    // CV Mode
    if (currentMode === "cv") {
      try {
        // Upload CV
        const res = await uploadCV({
          userId: "user123",
          rawText: input,
        }).unwrap();

        // ✅ Show popup for upload result
        toast.success(res.message);

        // Now trigger analysis
        const analysis = await analyzeCV(res.details.cvId).unwrap();

        // Add analysis feedback as AI message
        aiResponse = `📊 CV Analysis:\n\n**Summary**: ${analysis.details.suggestions.CVs.summary}\n\n**Strengths**: ${analysis.details.suggestions.CVFeedback.strengths}\n\n**Weaknesses**: ${analysis.details.suggestions.CVFeedback.weaknesses}\n\n**Improvement**: ${analysis.details.suggestions.CVFeedback.improvementSuggestions}`;
      } catch (err: any) {
        toast.error("Failed to upload CV. Please try again.");
      }
    } else if (lowerInput.includes("job")) {
      aiResponse =
        language === "en"
          ? "Okay, let me search for job opportunities that match your skills..."
          : "እሺ፣ ከችሎታዎችዎ ጋር የሚስማሙ የስራ እድሎችን እፈልጋለሁ...";
    } else if (lowerInput.includes("interview")) {
      aiResponse =
        language === "en"
          ? "Great! Let’s practice. Can you tell me how you would introduce yourself in an interview?"
          : "በጣም ጥሩ! እንልማመድ። በቃለመጠይቅ ላይ ራስዎን እንዴት እንደምትወያዩ ትንሽ ትንታኔ ትሰጡኝ?";
    } else if (lowerInput.includes("skill")) {
      aiResponse =
        language === "en"
          ? "Let’s assess your skills. Can you list the main technical and soft skills you have?"
          : "እንደመጀመሪያ ችሎታዎችዎን እንመዝግብ። ዋናዎቹ ቴክኒካዊና ሶፍት ችሎታዎችዎን ትጠቅሱልኝ?";
    } else {
      aiResponse =
        language === "en"
          ? "Thanks for your message! Can you clarify if you’d like help with CV, job search, interview practice, or skills?"
          : "እናመሰግናለን! ከCV፣ ከስራ ፍለጋ፣ ከቃለመጠይቅ ልምምድ፣ ወይም ከችሎታዎች ውስጥ የትኛውን ርዳታ እንደሚፈልጉ ይገልጹኝ።";
    }

    // Add AI response after delay
    setTimeout(() => {
      setMessages((prev) => [
        ...prev,
        {
          id: Date.now(),
          text: aiResponse,
          sender: "ai",
          time: formatTime(),
        },
      ]);
    }, 1000);

    setInput("");
  };

  const handleQuickAction = (action: "cv" | "jobs" | "interview") => {
    // setCurrentMode(action)

    const actionMessages = {
      cv:
        language === "en"
          ? "I'd like help reviewing my CV and getting feedback on how to improve it."
          : "CVዬን በመገምገም እና እንዴት ማሻሻል እንደምችል ግብረመልስ ማግኘት እፈልጋለሁ።",
      jobs:
        language === "en"
          ? "Can you help me find job opportunities that match my skills?"
          : "ከችሎታዎቼ ጋር የሚስማሙ የስራ እድሎችን እንዳገኝ ልትረዱኝ ትችላላችሁ?",
      interview:
        language === "en"
          ? "I want to practice interview questions and get feedback on my answers."
          : "የቃለ መጠይቅ ጥያቄዎችን መለማመድ እና በመልሶቼ ላይ ግብረመልስ ማግኘት እፈልጋለሁ።",
      skills:
        language === "en"
          ? "I'd like to assess my skills and get a personalized learning path."
          : "ችሎታዎችዎን ለመገምገም እና የግል የመማሪያ መንገድ ለማግኘት እፈልጋለሁ።",
    };
    setMode(action);
    setInput(actionMessages[action]);

    // setInputMessage(actionMessages[action])
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
      {/* Input / Mode-specific UI */}
      <div className="px-4 py-4 bg-[#BEE3DC] text-black justify-center">
        {mode === "skills" ? (
          // Show CV progressive input instead of normal chat
          <CVProgressive language={language} />
        ) : (
          <>
            {/* Quick Actions Row */}
            <div>
              <QuickActions handleQuickAction={handleQuickAction} />
            </div>

            {/* Input + Send Button Row */}
            <div className="flex items-center gap-2 w-full pb-1">
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
          </>
        )}
      </div>
    </div>
  );
}
