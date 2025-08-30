"use client";

import { useState, useRef, useEffect } from "react";
import { Button } from "../ui/Button";
import { Upload, FileText, Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";

interface CVProgressiveProps {
  language: "en" | "am";
}

interface Message {
  sender: "user" | "ai";
  content: string;
}

// --- Card Component ---
function Card({ className, ...props }: React.ComponentProps<"div">) {
  return (
    <div
      className={cn(
        "bg-white flex flex-col gap-6 rounded-xl border p-6 shadow-sm",
        className
      )}
      {...props}
    />
  );
}

// --- Textarea Component ---
function Textarea({ className, ...props }: React.ComponentProps<"textarea">) {
  return (
    <textarea
      className={cn(
        "border placeholder:text-gray-400 focus-visible:border-blue-500 focus-visible:ring-blue-300 flex min-h-16 w-full rounded-md px-3 py-2 text-base shadow-sm outline-none focus-visible:ring-2 disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
        className
      )}
      {...props}
    />
  );
}

export function CVProgressive({ language }: CVProgressiveProps) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [currentInput, setCurrentInput] = useState("");
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [uploadMethod, setUploadMethod] = useState<"text" | "file">("text");
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Scroll to bottom on new message
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const handleAnalyze = async () => {
    if (!currentInput.trim()) return;

    const newUserMessage: Message = { sender: "user", content: currentInput };
    setMessages((prev) => [...prev, newUserMessage]);
    setCurrentInput("");
    setIsAnalyzing(true);

    try {
      const response = await fetch("/api/analyze-cv-progressive", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          messages: [...messages, newUserMessage],
          language,
        }),
      });

      const result = await response.json();
      if (result.success && result.aiMessage) {
        setMessages((prev) => [
          ...prev,
          { sender: "ai", content: result.aiMessage },
        ]);
      }
    } catch (error) {
      console.error("Analysis failed:", error);
      setMessages((prev) => [
        ...prev,
        {
          sender: "ai",
          content:
            language === "en"
              ? "Analysis failed. Please try again."
              : "ትንተና አልተሳካም። እባክዎን ደግመው ይሞክሩ።",
        },
      ]);
    } finally {
      setIsAnalyzing(false);
    }
  };

  const handleFileUpload = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (
      file &&
      (file.type === "text/plain" || file.type === "application/pdf")
    ) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const content = e.target?.result as string;
        setCurrentInput(content);
      };
      reader.readAsText(file);
    }
  };

  return (
    <Card>
      <div className="flex items-center gap-2 mb-4">
        <FileText className="h-5 w-5 text-blue-600" />
        <h3 className="font-semibold">
          {language === "en" ? "Progressive CV Input" : "የCV ቀጣይ ማስገቢያ"}
        </h3>
      </div>

      {/* Upload / Input Switch */}
      <div className="flex gap-2 mb-4">
        <Button
          variant={uploadMethod === "text" ? "default" : "outline"}
          size="sm"
          onClick={() => setUploadMethod("text")}
        >
          {language === "en" ? "Type/Paste" : "ይጻፉ/ይለጥፉ"}
        </Button>
        <Button
          variant={uploadMethod === "file" ? "default" : "outline"}
          size="sm"
          onClick={() => setUploadMethod("file")}
        >
          {language === "en" ? "Upload File" : "ፋይል ይስቀሉ"}
        </Button>
      </div>

      {/* Chat Box */}
      <div className="border rounded-md p-4 h-[300px] overflow-y-auto space-y-3 bg-gray-50">
        {messages.map((msg, idx) => (
          <div
            key={idx}
            className={`flex ${
              msg.sender === "user" ? "justify-end" : "justify-start"
            }`}
          >
            <div
              className={`px-3 py-2 rounded-lg max-w-[70%] ${
                msg.sender === "user"
                  ? "bg-blue-500 text-white"
                  : "bg-gray-200 text-gray-900"
              }`}
            >
              {msg.content}
            </div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      {/* Input / Upload */}
      {uploadMethod === "text" ? (
        <Textarea
          value={currentInput}
          onChange={(e) => setCurrentInput(e.target.value)}
          placeholder={
            language === "en"
              ? "Type a section of your CV here..."
              : "የCV ክፍል ይጻፉ..."
          }
          className="min-h-[100px] resize-none"
        />
      ) : (
        <div className="border-2 border-dashed border-gray-300 rounded-lg p-4 text-center">
          <Upload className="h-6 w-6 text-gray-400 mx-auto mb-2" />
          <p className="text-sm text-gray-500 mb-2">
            {language === "en"
              ? "Upload your CV file (PDF or text)"
              : "የCV ፋይልዎን ይስቀሉ (PDF ወይም ጽሑፍ)"}
          </p>
          <input
            type="file"
            accept=".txt,.pdf"
            onChange={handleFileUpload}
            className="hidden"
            id="cv-upload"
          />
          <Button asChild variant="outline" size="sm">
            <label htmlFor="cv-upload" className="cursor-pointer">
              {language === "en" ? "Choose File" : "ፋይል ይምረጡ"}
            </label>
          </Button>
        </div>
      )}

      {/* Send Button */}
      <Button
        onClick={handleAnalyze}
        disabled={!currentInput.trim() || isAnalyzing}
        className="w-full mt-2 flex justify-center items-center"
      >
        {isAnalyzing ? (
          <>
            <Loader2 className="h-4 w-4 mr-2 animate-spin" />
            {language === "en" ? "Analyzing..." : "በመተንተን ላይ..."}
          </>
        ) : language === "en" ? (
          "Send Section"
        ) : (
          "ክፍል ላክ"
        )}
      </Button>
    </Card>
  );
}
