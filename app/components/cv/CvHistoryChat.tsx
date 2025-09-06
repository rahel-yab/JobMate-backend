"use client";
import { useState, useEffect, useRef } from "react";
import {
  useGetChatHistoryQuery,
  useSendMessageMutation,
} from "@/lib/redux/api/cvApi";
import ChatMessage from "../ChatMessage";
import { formatTime } from "@/lib/utils";

export default function CvHistoryChat({ chatId }: { chatId: string }) {
  const { data, isLoading } = useGetChatHistoryQuery({ chat_id: chatId });
  const [sendMessage] = useSendMessageMutation();
  const [input, setInput] = useState("");
  const [messages, setMessages] = useState<any[]>([]);
  const scrollRef = useRef<HTMLDivElement>(null);

  // When data loads, initialize messages and save cv_id in localStorage
  useEffect(() => {
    if (data) {
      setMessages(data.messages || []);
      if (data.cv_id) {
        localStorage.setItem("cv_chat_id", chatId);
        localStorage.setItem("cv_id", data.cv_id);
      }
    }
  }, [data, chatId]);

  // Scroll to bottom on new message
  useEffect(() => {
    scrollRef.current?.scrollTo({
      top: scrollRef.current.scrollHeight,
      behavior: "smooth",
    });
  }, [messages]);

  const handleSend = async () => {
    if (!input.trim()) return;

    const userMsg = {
      id: Date.now(),
      role: "user",
      content: input,
      timestamp: new Date().toISOString(),
    };

    setMessages((prev) => [...prev, userMsg]);
    setInput("");

    try {
      const cv_id = localStorage.getItem("cv_id") || undefined;
      const res = await sendMessage({
        chat_id: chatId,
        message: userMsg.content,
        cv_id,
      }).unwrap();

      const aiMsg = {
        id: Date.now() + 1,
        role: "ai",
        content: res.content,
        time: formatTime(res.data.timestamp),
      };

      setMessages((prev) => [...prev, aiMsg]);
    } catch (err) {
      console.error(err);
      setMessages((prev) => [
        ...prev,
        {
          id: Date.now() + 2,
          role: "assistant",
          content: "⚠️ Something went wrong sending your message.",
          timestamp: new Date().toISOString(),
        },
      ]);
    }
  };

  if (isLoading) return <div>Loading chat...</div>;

  return (
    <div className="flex flex-col h-full">
      <div className="flex-1 overflow-y-auto" ref={scrollRef}>
        {messages.map((msg: any) => (
          <ChatMessage
            key={msg.id}
            message={{
              sender: msg.role === "user" ? "user" : "ai",
              text: msg.content,
              time: formatTime(msg.timestamp),
            }}
          />
        ))}
      </div>

      <div className="mt-2 flex gap-2">
        <input
          type="text"
          className="flex-1 border rounded p-2"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Type a message..."
        />
        <button
          className="bg-[#217C6A] text-white px-4 rounded"
          onClick={handleSend}
        >
          Send
        </button>
      </div>
    </div>
  );
}
