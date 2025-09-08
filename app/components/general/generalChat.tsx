"use client";
import { useState } from "react";
import { formatTime } from "@/lib/utils";
import ChatWindow from "@/app/components/ChatWindow";
import { useSendMessageMutation } from "@/lib/redux/api/generalApi";
import ChatMessage from "../ChatMessage";
import { useLanguage } from "@/providers/language-provider";
import { Message } from "../ChatWindow";

export default function GeneralChat() {
  const { t } = useLanguage();
  const [messages, setMessages] = useState<Message[]>([
    {
      id: Date.now().toString(),
      type: "text",
      sender: "ai",
      text: t("generalWelcomeMessage"),
      time: formatTime(new Date()),
    },
  ]);
  const [input, setInput] = useState("");
  const [sendMessage] = useSendMessageMutation();

  const handleSend = async () => {
    if (!input.trim()) return;

    const text = input;
    setInput("");

    const userMsg: Message = {
      id: Date.now().toString(),
      type: "text",
      sender: "user",
      text,
      time: formatTime(new Date()),
    };
    setMessages((prev) => [...prev, userMsg]);

    try {
      const res = await sendMessage({
        user_id: "mock-user-123",
        message: text,
        is_from_user: true,
      }).unwrap();

      const aiMsg: Message = {
        id: Date.now().toString(),
        type: "text",
        sender: "ai",
        text: res.reply,
        time: formatTime(new Date()),
      };
      setMessages((prev) => [...prev, aiMsg]);
    } catch {
      setMessages((prev) => [
        ...prev,
        {
          id: Date.now().toString(),
          type: "text",
          sender: "ai",
          text: "Something went wrong. Try again.",
          time: formatTime(new Date()),
        },
      ]);
    }
  };

  return (
    <ChatWindow
      messages={messages}
      input={input}
      setInput={setInput}
      onSend={handleSend}
      renderMessage={(msg) => <ChatMessage key={msg.id} message={msg} />}
    />
  );
}
