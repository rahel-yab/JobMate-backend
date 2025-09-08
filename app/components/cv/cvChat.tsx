"use client";

import { useState, useEffect } from "react";
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

// Define types for messages
interface Message {
  id: number;
  sender: "user" | "ai";
  text?: string | JSX.Element;
  time: string;
  type?: "cv-analysis";
  summary?: string;
  strengths?: string;
  weaknesses?: string;
  improvements?: string;
  skillGaps?: SkillGap[];
}

interface SkillGap {
  skillName: string;
  currentLevel: number;
  recommendedLevel: number;
  importance: "important" | "optional";
  improvementSuggestions: string[];
}

export default function CvChat() {
  const { language } = useLanguage();

  const t = (key: string) => {
    const translations: Record<string, { en: string; am: string }> = {
      cvWelcomeMessage: {
        en: "Welcome! Upload your CV to get started.",
        am: "እንኳን ደህና መጡ! ለመጀመር የCVዎን ያስገቡ።",
      },
      uploadError: {
        en: "⚠️ Sorry, something went wrong while uploading your CV. Please try again later.",
        am: "⚠️ ይቅርታ፣ በCVዎ ላይ ማስገባት ላይ ችግር ተነስቷል። እባክዎን ከዚህ በኋላ ደግመው ይሞክሩ።",
      },
      analyzeError: {
        en: "⚠️ Could not find analysis suggestions for your CV. Please try again.",
        am: "⚠️ ለCVዎ የትንተና ምክሮች ማግኘት አልቻልንም። እባክዎን ደግመው ይሞክሩ።",
      },
      analyzeFail: {
        en: "⚠️ Sorry, I couldn’t analyze your CV right now. Please try again later.",
        am: "⚠️ ይቅርታ፣ አሁን ለCVዎ ትንተና ማድረግ አልቻልንም። እባክዎን ከዚህ በኋላ ደግመው ይሞክሩ።",
      },
      chatDirect: {
        en: "Okay, let's chat directly about your CV. Ask me anything!",
        am: "እሺ፣ በቀጥታ ስለ CVዎ እንገናኝ። ማንኛውንም ጥያቄ ጠይቁኝ!",
      },
    };
    return translations[key]?.[language] || key;
  };

  const [messages, setMessages] = useState<Message[]>([
    {
      id: Date.now(),
      sender: "ai",
      text: t("cvWelcomeMessage"),
      time: formatTime(new Date()),
    },
  ]);
  const [input, setInput] = useState<string>("");
  const [chatId, setChatId] = useState<string | null>(null);

  const [uploadCV] = useUploadCVMutation();
  const [analyzeCV] = useAnalyzeCVMutation();
  const [startSession] = useStartSessionMutation();
  const [sendMessage] = useSendMessageMutation();
  const router = useRouter();

  useEffect(() => {
    return () => {
      localStorage.removeItem("cv_id");
      localStorage.removeItem("cv_chat_id");
    };
  }, []);

  const handleUpload = async (data: { rawText?: string; file?: File }) => {
    try {
      const res = await uploadCV({
        rawText: data.rawText,
        file: data.file,
      }).unwrap();

      const msg: Message = {
        id: Date.now(),
        sender: "ai",
        text: res.success
          ? `📄 ${res.message}: ${res.data?.fileName || ""}`
          : `⚠️ ${res.message}`,
        time: formatTime(new Date()),
      };
      console.log(msg);
      // setMessages((prev) => [...prev, msg]);

      if (res.success) {
        const newCvId = res.data.cvId;
        localStorage.setItem("cv_id", newCvId);
        handleAnalyze(newCvId);
      }
    } catch (error) {
      console.log(error);
      setMessages((prev) => [
        ...prev,
        {
          id: Date.now(),
          sender: "ai",
          text: t("uploadError"),
          time: formatTime(new Date()),
        },
      ]);
    }
  };

  const handleAnalyze = async (id: string) => {
    try {
      const res = await analyzeCV(id).unwrap();

      const suggestions = res.data?.suggestions;
      if (!suggestions) {
        setMessages((prev) => [
          ...prev,
          {
            id: Date.now(),
            sender: "ai",
            text: t("analyzeError"),
            time: formatTime(new Date()),
          },
        ]);
        return;
      }

      const { CVs, CVFeedback, SkillGaps } = suggestions;

      const normalizedSkillGaps: SkillGap[] = (SkillGaps || []).map(
        (gap: any) => ({
          skillName: gap.SkillName,
          currentLevel: gap.CurrentLevel,
          recommendedLevel: gap.RecommendedLevel,
          importance:
            gap.Importance?.toLowerCase() === "critical"
              ? "important"
              : gap.Importance?.toLowerCase(),
          improvementSuggestions: gap.ImprovementSuggestions,
        })
      );

      const cvMsg: Message = {
        id: Date.now(),
        sender: "ai",
        type: "cv-analysis",
        summary: CVs?.Summary || "",
        strengths: CVFeedback?.Strengths || "",
        weaknesses: CVFeedback?.Weaknesses || "",
        improvements: CVFeedback?.ImprovementSuggestions || "",
        skillGaps: normalizedSkillGaps,
        time: formatTime(new Date()),
      };

      setMessages((prev) => [...prev, cvMsg]);
    } catch (error) {
      console.log(error);
      setMessages((prev) => [
        ...prev,
        {
          id: Date.now(),
          sender: "ai",
          text: t("analyzeFail"),
          time: formatTime(new Date()),
        },
      ]);
    }
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

  const handleSend = async () => {
    if (!input.trim()) return;

    const text = input;
    setInput("");

    const userMsg: Message = {
      id: Date.now(),
      sender: "user",
      text,
      time: formatTime(new Date()),
    };
    setMessages((prev) => [...prev, userMsg]);

    try {
      const cv_id = localStorage.getItem("cv_id") || "undefined";
      const cid = await ensureSession(cv_id);
      const res = await sendMessage({
        chat_id: cid,
        message: text,
        cv_id,
      }).unwrap();

      const aiMsg: Message = {
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
            summary={msg.summary!}
            strengths={msg.strengths!}
            weaknesses={msg.weaknesses!}
            improvements={msg.improvements!}
            skillGaps={msg.skillGaps!}
          />
        ) : (
          <React.Fragment key={msg.id}>
            <ChatMessage message={msg} />
            {messages.length === 1 && (
              <CvAnalysisCard
                onAnalyze={handleUpload}
                onChatInstead={async () => {
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
