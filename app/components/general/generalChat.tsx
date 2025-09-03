"use client";
import { useState } from "react";
import { formatTime } from "@/lib/utils";
import ChatWindow from "@/app/components/ChatWindow";
import { useSendMessageMutation } from "@/lib/redux/api/generalApi";
import ChatMessage from "../ChatMessage";

export default function GeneralChat() {
  const [messages, setMessages] = useState<any[]>([]);
  const [input, setInput] = useState("");
  const [sendMessage] = useSendMessageMutation();

  const handleSend = async () => {
    if (!input.trim()) return;

    const text = input;
    setInput("");

    const userMsg: any = {
      id: Date.now(),
      type: "text",
      sender: "user",
      text,
      time: formatTime(),
    };
    setMessages((prev) => [...prev, userMsg]);

    try {
      const res = await sendMessage({
        user_id: "mock-user-123",
        message: text,
        is_from_user: true,
      }).unwrap();

      const aiMsg: any = {
        id: Date.now(),
        type: "text",
        sender: "ai",
        text: res.reply,
        time: formatTime(),
      };
      setMessages((prev) => [...prev, aiMsg]);
    } catch {
      setMessages((prev) => [
        ...prev,
        {
          id: Date.now(),
          type: "text",
          sender: "ai",
          text: "Something went wrong. Try again.",
          time: formatTime(),
        },
      ]);
    }
  };

  const handleQuickAction = () => {};

  return (
    <ChatWindow
      messages={messages}
      onQuickAction={handleQuickAction}
      input={input}
      setInput={setInput}
      onSend={handleSend}
      renderMessage={(msg) => <ChatMessage key={msg.id} message={msg} />}
    />
  );
}
