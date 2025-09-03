"use client";

import { useState } from "react";
import React from "react";
import { formatTime } from "@/lib/utils";
import CvWindow from "./CvWindow"; // 👈 Capitalized
import CVMessage from "./CVMessage";
import ChatMessage from "../ChatMessage";
import CvAnalysisCard from "./CvAnalysis";
import {
  useUploadCVMutation,
  useAnalyzeCVMutation,
} from "@/lib/redux/api/cvApi";
import { useLanguage } from "@/providers/language-provider";

export default function CvChat() {
  const { language } = useLanguage();

  const [messages, setMessages] = useState<any[]>([
    {
      id: Date.now(),
      sender: "ai",
      text:
        language === "en"
          ? "Great! I'd be happy to help you with your CV. You can upload your current CV or describe your background below, and I'll provide detailed feedback to help you improve it."
          : "የእርስዎን CV በመልእክት ይላኩ ወይም ፋይሉን ጫኑ።",
      time: formatTime(),
    },
  ]);

  const [input, setInput] = useState("");

  const [uploadCV] = useUploadCVMutation();
  const [analyzeCV] = useAnalyzeCVMutation();

  // mock CV upload
  const handleUpload = async (cv: string) => {
    const res = await uploadCV({ userId: "user123", rawText: cv }).unwrap();
    const msg = {
      id: Date.now(),
      sender: "ai",
      text: `📄 ${res.message}: ${res.details.fileName}`,
      time: formatTime(),
    };
    console.log(msg);

    const msg1 = {
      id: Date.now(),
      sender: "ai",
      text: `Here's your CV analysis with detailed feedback and suggestions for improvement:`,
      time: formatTime(),
    };
    setMessages((prev) => [...prev, msg1]);

    handleAnalyze();
  };

  // analyze CV
  const handleAnalyze = async () => {
    const res = await analyzeCV("abc123").unwrap();
    const { CVs, CVFeedback } = res.details.suggestions;

    const cvMsg = {
      id: Date.now(),
      sender: "ai",
      type: "cv-analysis",
      summary: CVs.summary,
      strengths: CVFeedback.strengths,
      weaknesses: CVFeedback.weaknesses,
      improvements: CVFeedback.improvementSuggestions,
      time: formatTime(),
    };

    setMessages((prev) => [...prev, cvMsg]);
  };

  const handleQuickAction = () => {};

  return (
    <CvWindow
      messages={messages}
      onQuickAction={handleQuickAction}
      renderMessage={(msg) =>
        msg.type === "cv-analysis" ? (
          <CVMessage
            key={msg.id}
            summary={msg.summary}
            strengths={msg.strengths}
            weaknesses={msg.weaknesses}
            improvements={msg.improvements}
          />
        ) : (
          <React.Fragment key={msg.id}>
            <ChatMessage message={msg} />

            {messages.length === 1 && (
              <CvAnalysisCard onAnalyze={handleUpload} />
            )}
          </React.Fragment>
        )
      }
    />
  );
}
