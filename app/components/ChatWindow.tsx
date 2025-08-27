"use client";
import { useState } from "react";
import ChatMessage from "./ChatMessage";

export default function ChatWindow() {
  const [messages, setMessages] = useState([
    { id: 1, text: "Hello, I am JobMate.", sender: "ai" },
  ]);
  const [input, setInput] = useState("");

  const sendMessage = () => {
    if (!input.trim()) return;

    const newMsg = { id: Date.now(), text: input, sender: "user" };
    setMessages([...messages, newMsg]);

    setTimeout(() => {
      setMessages((prev) => [
        ...prev,
        { id: Date.now(), text: "Got it! I'm JobMate.", sender: "ai" },
      ]);
    }, 1000);

    setInput("");
  };

  return (
    <div className="flex flex-col w-full max-w-md h-[600px] bg-white rounded-2xl shadow-lg p-4">
      <div className="flex-1 overflow-y-auto space-y-2">
        {messages.map((msg) => (
          <ChatMessage key={msg.id} text={msg.text} sender={msg.sender} />
        ))}
      </div>
      <div className="flex items-center gap-2 mt-2">
        <input
          className="flex-1 border rounded-lg px-3 py-2"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Type a message..."
        />
        <button
          onClick={sendMessage}
          className="bg-blue-500 text-white px-4 py-2 rounded-lg"
        >
          Send
        </button>
      </div>
    </div>
  );
}
