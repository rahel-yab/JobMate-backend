"use client";
import { Send } from "lucide-react";
import { useLanguage } from "@/providers/language-provider";

interface ChatInputProps {
  input: string;
  setInput: (val: string) => void;
  onSend: () => void;
}

export default function ChatInput({ input, setInput, onSend }: ChatInputProps) {
  const { language } = useLanguage();
  return (
    <div className="flex items-center gap-2 w-full">
      <input
        className="flex-1 bg-white shadow-md rounded-md px-4 py-2.5 focus:outline-none focus:shadow-[0_0_8px_2px_rgba(40,149,127,0.7)]"
        value={input}
        onChange={(e) => setInput(e.target.value)}
        onKeyDown={(e) => {
          if (e.key === "Enter") {
            e.preventDefault();
            onSend();
          }
        }}
        placeholder={language === "en" ? "Type a message..." : "መልእክት ያድርጉ..."}
      />
      <button
        onClick={onSend}
        className="bg-[#0F3A31] hover:bg-[#217C6A] p-3 rounded-lg text-white flex items-center justify-center"
      >
        <Send className="h-5 w-5" />
      </button>
    </div>
  );
}
