"use client";

import React, { useEffect, useState } from "react";
import { formatTime } from "@/lib/utils";
import CvWindow from "./CvWindow";
import CVMessage from "./CVMessage";
import ChatMessage from "../ChatMessage";
import ReactMarkdown from "react-markdown";
import {
  useGetChatHistoryQuery,
  useSendMessageMutation,
} from "@/lib/redux/api/cvApi";

interface CvExistingChatProps {
  chatId: string;
  onBack: () => void;
}

export default function CvExistingChat({
  chatId,
  onBack,
}: CvExistingChatProps) {
  const { data, isLoading } = useGetChatHistoryQuery({ chat_id: chatId });
  const [sendMessage] = useSendMessageMutation();

  const [messages, setMessages] = useState<any[]>([]);
  const [input, setInput] = useState("");
  const [cvId, setCvId] = useState<string | null>(null);

  // Load messages + capture cvId from API
  useEffect(() => {
    if (data) {
      if (data.cv_id) {
        setCvId(data.cv_id);
        localStorage.setItem("cv_id", data.cv_id); // optional persistence
      }

      if (data.messages) {
        const formatted = data.messages.map((m: any) => ({
          id: m.id,
          sender: m.role === "assistant" ? "ai" : "user",
          text: <ReactMarkdown>{m.content}</ReactMarkdown>,
          time: formatTime(new Date(m.timestamp)),
        }));
        setMessages(formatted);
      }
    }
  }, [data]);

  const handleSend = async () => {
    if (!input.trim()) return;
    const text = input;
    setInput("");

    // Add user message locally
    const userMsg = {
      id: Date.now(),
      sender: "user",
      text,
      time: formatTime(new Date()),
    };
    setMessages((prev) => [...prev, userMsg]);

    try {
      const res = await sendMessage({
        chat_id: chatId,
        message: text,
        ...(cvId ? { cv_id: cvId } : {}), // attach cvId if available
      }).unwrap();

      const aiMsg = {
        id: Date.now(),
        sender: "ai",
        text: <ReactMarkdown>{res.content}</ReactMarkdown>,
        time: formatTime(new Date(res.timestamp)),
      };
      setMessages((prev) => [...prev, aiMsg]);
    } catch {
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

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-64 text-gray-500">
        Loading chat...
      </div>
    );
  }

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
          <ChatMessage key={msg.id} message={msg} />
        )
      }
      input={input}
      setInput={setInput}
      onSend={handleSend}
      onBack={onBack}
    />
  );
}
