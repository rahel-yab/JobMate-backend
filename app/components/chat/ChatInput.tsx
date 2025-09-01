"use client";
import { useState } from "react";
import { Send } from "lucide-react";
import toast from "react-hot-toast";
import {
  useUploadCVMutation,
  useAnalyzeCVMutation,
} from "@/lib/redux/api/cvApi";
import { useLanguage } from "@/context/language-provider";
//import { message } from "@/lib/types";
import { formatTime } from "@/lib/utils";

interface ChatInputProps {
  input: string;
  setInput: (val: string) => void;
  setMessages: React.Dispatch<React.SetStateAction<any[]>>;
  mode: "cv" | "jobs" | "interview" | "skills" | "chat";
  cvPromptVisible: boolean;
  setCvPromptVisible: React.Dispatch<React.SetStateAction<boolean>>;
}

export default function ChatInput({
  input,
  setInput,
  setMessages,
  mode,
  cvPromptVisible,
  setCvPromptVisible,
}: ChatInputProps) {
  const { language } = useLanguage();
  const [cvTextInput, setCvTextInput] = useState("");
  const [uploadCV] = useUploadCVMutation();
  const [analyzeCV] = useAnalyzeCVMutation();

  /** --- Handle Sending Normal Chat Messages --- **/
  const sendMessage = () => {
    if (!input.trim()) return;

    // Normal chat message
    const newMsg = {
      id: Date.now(),
      type: "text",
      sender: "user",
      text: input,
      time: formatTime(),
    };
    setMessages((prev) => [...prev, newMsg]);

    // AI response simulation
    const lowerInput = input.toLowerCase();
    let aiResponse = "";
    if (lowerInput.includes("job"))
      aiResponse =
        language === "en"
          ? "Searching for jobs matching your skills..."
          : "ከችሎታዎችዎ ጋር የሚስማሙ ስራዎችን እፈልጋለሁ...";
    else if (lowerInput.includes("cv")) {
      setCvPromptVisible(true);
      aiResponse =
        language === "en"
          ? "send your cv or upload."
          : "የእርስዎን CV በመልእክት ይላኩ ወይም ፋይሉን ጫኑ።";
    } else if (lowerInput.includes("interview"))
      aiResponse =
        language === "en"
          ? "Let's practice interview questions."
          : "የቃለመጠይቅ ጥያቄዎችን እንልማመድ።";
    else if (lowerInput.includes("skill"))
      aiResponse =
        language === "en" ? "Let's assess your skills." : "ችሎታዎችዎን እንገምግማለን።";
    else
      aiResponse =
        language === "en"
          ? "Can you clarify what you need help with?"
          : "ምን እንደምትፈልጉ ይገልጹ።";

    setTimeout(() => {
      setMessages((prev) => [
        ...prev,
        {
          id: Date.now(),
          type: "text",
          sender: "ai",
          text: aiResponse,
          time: formatTime(),
        },
      ]);
    }, 500);

    setInput("");
  };

  /** --- Handle Sending CV Content --- **/
  const sendCV = async () => {
    if (!cvTextInput.trim()) return;

    const userCvMsg = {
      id: Date.now(),
      type: "cv",
      sender: "user",
      text: cvTextInput,
      time: formatTime(),
    };
    setMessages((prev) => [...prev, userCvMsg]);

    const text = cvTextInput;
    setCvTextInput("");

    try {
      const res = await uploadCV({ userId: "user123", rawText: text }).unwrap();
      console.log(res.message);

      const analysis = await analyzeCV(res.details.cvId).unwrap();
      const cvMsg = {
        id: Date.now(),
        sender: "ai",
        type: "cv",
        time: formatTime(),
        summary: analysis.details.suggestions.CVs.summary,
        strengths: analysis.details.suggestions.CVFeedback.strengths,
        weaknesses: analysis.details.suggestions.CVFeedback.weaknesses,
        improvements:
          analysis.details.suggestions.CVFeedback.improvementSuggestions,
      };

      setTimeout(() => {
        setMessages((prev) => [...prev, cvMsg]);
      }, 1000);

      setCvPromptVisible(false);
    } catch (err) {
      console.warn("Failed to upload CV. Please try again.");
    }
  };

  return (
    <div className="flex items-center gap-2 w-full pb-1">
      {cvPromptVisible ? (
        <>
          <input
            className="flex-1 bg-white shadow-md rounded-md px-4 py-2.5 focus:outline-none focus:shadow-[0_0_8px_2px_rgba(40,149,127,0.7)]"
            value={cvTextInput}
            onChange={(e) => setCvTextInput(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && sendCV()}
            placeholder={
              language === "en" ? "Paste your CV here..." : "CVዎን እዚህ ያስገቡ..."
            }
          />
          <button
            onClick={sendCV}
            className="bg-[#0F3A31] hover:bg-[#217C6A] p-3 rounded-lg text-white flex items-center justify-center"
          >
            <Send className="h-5 w-5" />
          </button>
        </>
      ) : (
        <>
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
        </>
      )}
    </div>
  );
}
