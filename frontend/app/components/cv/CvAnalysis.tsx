"use client";

import { useState } from "react";
import { FileText, Upload, MessageCircle } from "lucide-react";

export default function CvAnalysisCard({
  onAnalyze,
  onChatInstead,
}: {
  onAnalyze: (data: { rawText?: string; file?: File }) => Promise<void>;
  onChatInstead: () => void;
}) {
  const [mode, setMode] = useState<"paste" | "upload">("paste");
  const [text, setText] = useState("");
  const [error, setError] = useState<string>("");
  const [file, setFile] = useState<File | null>(null);
  const [isAnalyzing, setIsAnalyzing] = useState(false); // New loading state

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = e.target.files?.[0];
    if (!selectedFile) return;

    const allowedExtensions = [".pdf", ".docx"];
    const fileName = selectedFile.name.toLowerCase();
    const isValid = allowedExtensions.some((ext) => fileName.endsWith(ext));

    if (!isValid) {
      setFile(null);
      setError("❌ Invalid file type. Please upload a PDF or DOCX file.");
      return;
    }

    setError("");
    setFile(selectedFile);
  };

  const handleUploadClick = () => {
    document.getElementById("hiddenFileInput")?.click();
  };

  const handleAnalyze = async () => {
    if (isDisabled || isAnalyzing) return; // prevent multiple clicks
    setIsAnalyzing(true);

    try {
      if (mode === "paste" && text.trim().length > 0) {
        await onAnalyze({ rawText: text });
      } else if (mode === "upload" && file) {
        await onAnalyze({ file });
      }
    } catch (err) {
      console.error(err);
    } finally {
      setIsAnalyzing(false);
    }
  };

  const isDisabled =
    isAnalyzing ||
    (mode === "paste" && text.trim().length <= 10) ||
    (mode === "upload" && !file);

  return (
    <div className="flex justify-start mb-3 ml-8 ">
      <div className="bg-[#E6FFFA] rounded-2xl p-4 max-w-[80%] w-full">
        {/* Header */}
        <div className="flex items-center gap-2 text-gray-700 font-semibold mb-4">
          <FileText className="h-5 w-5" />
          <span>CV Analysis</span>
        </div>

        {/* Mode Switch */}
        <div className="flex gap-2 mb-4">
          <button
            onClick={() => setMode("paste")}
            className={`px-4 py-1 rounded-md shadow-md border text-sm ${
              mode === "paste"
                ? "hover:bg-[#217C6A] text-white border-[#217C6A] bg-[#007459]"
                : "bg-white text-gray-700 border-gray-300"
            }`}
          >
            Type/Paste
          </button>
          <button
            onClick={() => setMode("upload")}
            className={`px-4 py-1 rounded-md border shadow-md text-sm ${
              mode === "upload"
                ? "bg-[#217C6A] text-white border-[#217C6A] hover:bg-[#195d50]"
                : "bg-white text-gray-700 border-gray-300"
            }`}
          >
            Upload File
          </button>
        </div>

        {/* Input */}
        {mode === "paste" ? (
          <textarea
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder="Paste your CV content here..."
            className="w-full text-black border border-white h-60 p-3 rounded-md shadow-md focus:ring-1 focus:ring-[#217C6A] focus:outline-none"
          />
        ) : (
          <div
            onClick={handleUploadClick}
            className="w-full h-60 border-2 border-dashed rounded-md flex flex-col items-center justify-center cursor-pointer hover:bg-gray-100 transition"
          >
            <Upload className="h-10 w-10 text-gray-500 mb-2" />
            {file ? (
              <span className="text-sm text-gray-700">{file.name}</span>
            ) : (
              <span className="text-sm text-gray-500">
                Supports PDF and DOCX files up to 10MB
              </span>
            )}
            <input
              id="hiddenFileInput"
              type="file"
              accept=".pdf,.docx"
              onChange={handleFileChange}
              className="hidden"
            />
            {error && (
              <div className="mt-2 text-sm text-[#B45309] bg-[#FEF3C7] border border-[#FCD34D] px-3 py-2 rounded-md">
                {error}
              </div>
            )}
          </div>
        )}

        {/* Analyze Button */}
        <button
          onClick={handleAnalyze}
          disabled={isDisabled}
          className={`w-full mt-4 font-semibold py-3 rounded-md transition ${
            isDisabled
              ? "bg-[#6f958c] text-[#7ebeaf] cursor-not-allowed"
              : "hover:bg-[#217C6A] bg-[#007459] text-white"
          }`}
        >
          {isAnalyzing ? "Analyzing..." : "Analyze My CV"}
        </button>

        <button
          onClick={onChatInstead}
          className="w-full mt-3 font-semibold py-3 rounded-md transition bg-white border border-[#217C6A] text-[#217C6A] hover:bg-[#E6F4F1] flex items-center justify-center gap-2"
        >
          <MessageCircle className="h-5 w-5" />
          Chat About My CV Instead
        </button>
      </div>
    </div>
  );
}
