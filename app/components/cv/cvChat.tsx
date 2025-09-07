"use client";

import { useState } from "react";
import React from "react";
import { formatTime } from "@/lib/utils";
import CvWindow from "./CvWindow";
import CVMessage from "./CVMessage";
import ChatMessage from "../ChatMessage";
import CvAnalysisCard from "./CvAnalysis";
import { useRouter } from "next/navigation";
import ReactMarkdown from "react-markdown";
import {
  useUploadCVMutation,
  useAnalyzeCVMutation,
  useStartSessionMutation,
  useSendMessageMutation,
} from "@/lib/redux/api/cvApi";
import { useLanguage } from "@/providers/language-provider";

export default function CvChat() {
  const { t } = useLanguage();

  const [messages, setMessages] = useState<any[]>([
    {
      id: Date.now(),
      sender: "ai",
      text: t("cvWelcomeMessage"),
      time: formatTime(new Date()),
    },
  ]);
  const [input, setInput] = useState("");
  const [chatId, setChatId] = useState<string | null>(null);
  // const [cvId, setCvId] = useState<string | null>(null);

  const [uploadCV] = useUploadCVMutation();
  const [analyzeCV] = useAnalyzeCVMutation();
  const [startSession] = useStartSessionMutation();
  const [sendMessage] = useSendMessageMutation();
  const router = useRouter();

  // upload
  const handleUpload = async (data: { rawText?: string; file?: File }) => {
    const res = await uploadCV({
      rawText: data.rawText,
      file: data.file,
    }).unwrap();

    const msg = {
      id: Date.now(),
      sender: "ai",
      text: res.success
        ? `📄 ${res.message}: ${res.deta?.fileName || ""}`
        : `⚠️ ${res.message}`, // backend failure messages
      cvId: res?.data?.cvId || "",
    };

    console.log(msg);

    const msg1 = {
      id: Date.now(),
      sender: "ai",
      text: `Here's your CV analysis with detailed feedback and suggestions for improvement:`,
      time: formatTime(new Date()),
    };
    setMessages((prev) => [...prev, msg1]);

    if (res.success) {
      const newCvId = res.data.cvId;
      //setCvId(newCvId);
      localStorage.setItem("cv_id", newCvId);
      handleAnalyze(newCvId);
    }
  };

  // analyze CV
  const handleAnalyze = async (id: string) => {
    const res = await analyzeCV(id).unwrap();
    const { CVs, CVFeedback, SkillGaps } = res.details.suggestions;

    const cvMsg = {
      id: Date.now(),
      sender: "ai",
      type: "cv-analysis",
      summary: CVs.summary, // ✅ camelCase
      strengths: CVFeedback.strengths,
      weaknesses: CVFeedback.weaknesses,
      improvements: CVFeedback.improvementSuggestions,
      skillGaps: SkillGaps,
      time: formatTime(new Date()),
    };

    setMessages((prev) => [...prev, cvMsg]);
  };

  const ensureSession = async (cvId?: string) => {
    if (!chatId) {
      const res = await startSession({ cv_id: cvId }).unwrap();
      setChatId(res.chat_id);
      localStorage.setItem("cv_chat_id", res.chat_id);
      return res.chat_id;
    }
    return chatId;
  };

  // Send message handler
  const handleSend = async () => {
    if (!input.trim()) return;

    const text = input;
    setInput("");

    const userMsg = {
      id: Date.now(),
      sender: "user",
      text,
      time: formatTime(new Date()),
    };
    setMessages((prev) => [...prev, userMsg]);

    try {
      const cv_id = localStorage.getItem("cv_id");
      const cid = await ensureSession(cv_id);
      const res = await sendMessage({
        chat_id: cid,
        message: text,
      }).unwrap();

      const aiMsg = {
        id: Date.now(),
        sender: "ai",
        text: <ReactMarkdown>{res.content}</ReactMarkdown>,
        time: formatTime(new Date(res.timestamp)),
      };
      setMessages((prev) => [...prev, aiMsg]);
    } catch (err) {
      setMessages((prev) => [
        ...prev,
        {
          id: Date.now(),
          sender: "ai",
          text: "⚠️ Something went wrong.",
          time: formatTime(new Date()),
        },
      ]);
    }
  };

  return (
    <CvWindow
      messages={messages}
      renderMessage={(msg) =>
        msg.type === "cv-analysis" ? (
          <CVMessage
            key={msg.id}
            summary={msg.summary}
            strengths={msg.strengths}
            weaknesses={msg.weaknesses}
            improvements={msg.improvements}
            skillGaps={msg.skillGaps}
          />
        ) : (
          <React.Fragment key={msg.id}>
            <ChatMessage message={msg} />

            {messages.length === 1 && (
              <CvAnalysisCard
                onAnalyze={handleUpload}
                onChatInstead={async () => {
                  const cid = await ensureSession();
                  setMessages((prev) => [
                    ...prev,
                    {
                      id: Date.now(),
                      sender: "ai",
                      text: "Okay, let's chat directly about your CV. Ask me anything!",
                      time: formatTime(new Date()),
                    },
                  ]);
                }}
              />
            )}
          </React.Fragment>
        )
      }
      input={input}
      setInput={setInput}
      onSend={handleSend}
      onBack={() => router.push("/cv")}
    />
  );
}
