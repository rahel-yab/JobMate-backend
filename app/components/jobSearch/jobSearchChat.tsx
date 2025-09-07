"use client";
import { useState } from "react";
import { formatTime } from "@/lib/utils";
import { useLanguage } from "@/providers/language-provider";
import { useSendMsgMutation } from "@/lib/redux/api/JobApi";
import JobChatWindow from "../JobChatWindow";
import ChatMessage from "../ChatMessage";

type Message = {
  id: number;
  sender: "user" | "ai";
  type: "text" | "jobs";
  text?: string;
  jobs?: any[];
  time: string;
};

// 🔑 helper for unique IDs
const uniqueId = () => Date.now() + Math.floor(Math.random() * 10000);

export default function JobSearchChat() {
  const { t } = useLanguage();
  const [messages, setMessages] = useState<Message[]>([
    {
      id: uniqueId(),
      type: "text",
      sender: "ai",
      text: t("generalWelcomeMessage"),
      time: formatTime(new Date()),
    },
  ]);
  const [input, setInput] = useState("");
  const [chatId, setChatId] = useState<string | null>(null);
  const [sendMessage] = useSendMsgMutation();

  const handleSend = async () => {
    if (!input.trim()) return;

    const userText = input;
    setInput("");

    const userMsg: Message = {
      id: uniqueId(),
      type: "text",
      sender: "user",
      text: userText,
      time: formatTime(new Date()),
    };
    setMessages((prev) => [...prev, userMsg]);

    try {
      const res = await sendMessage({
        message: userText,
        chat_id: chatId || undefined,
      }).unwrap();
      console.log(res);

      if (!chatId && res.chat_id) setChatId(res.chat_id);

      // If API returns plain text message
      if (res.message) {
        const aiMsg: Message = {
          id: uniqueId(),
          sender: "ai",
          type: "text",
          text: res.message,
          time: formatTime(new Date()),
        };
        setMessages((prev) => [...prev, aiMsg]);
      }

      // If API returns jobs, add as a "jobs" message
      if (res.jobs && res.jobs.length > 0) {
        const jobsMsg: Message = {
          id: uniqueId(),
          sender: "ai",
          type: "jobs",
          jobs: res.jobs,
          time: formatTime(new Date()),
        };
        setMessages((prev) => [...prev, jobsMsg]);
      }
    } catch {
      const errorMsg: Message = {
        id: uniqueId(),
        type: "text",
        sender: "ai",
        text: "Something went wrong. Try again.",
        time: formatTime(new Date()),
      };
      setMessages((prev) => [...prev, errorMsg]);
    }
  };

  return (
    <JobChatWindow
      messages={messages}
      input={input}
      setInput={setInput}
      onSend={handleSend}
      renderMessage={(msg) =>
        msg.type === "text" ? <ChatMessage key={msg.id} message={msg} /> : null
      }
    />
  );
}
