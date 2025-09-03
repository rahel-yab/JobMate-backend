"use client";

import { useState } from "react";
import { FileText, Upload } from "lucide-react";

export default function CvAnalysisCard({
  onAnalyze,
}: {
  onAnalyze: (cv: string) => void;
}) {
  const [mode, setMode] = useState<"paste" | "upload">("paste");
  const [text, setText] = useState("");
  const [fileName, setFileName] = useState<string | null>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setFileName(e.target.files[0].name);
    }
  };

  const handleUploadClick = () => {
    document.getElementById("hiddenFileInput")?.click();
  };

  return (
    <div className="flex justify-start mb-3 ml-8 ">
      <div className="bg-[#DFF2EE] rounded-2xl p-4 max-w-[80%] w-full">
        <div className="flex items-center gap-2 text-gray-700 font-semibold mb-4">
          <FileText className="h-5 w-5" />
          <span>CV Analysis</span>
        </div>

        <div className="flex gap-2 mb-4">
          <button
            onClick={() => setMode("paste")}
            className={`px-4 py-1 rounded-md shadow-md border text-sm ${
              mode === "paste"
                ? "bg-[#217C6A] text-white border-[#217C6A]"
                : "bg-white text-gray-700 border-gray-300"
            }`}
          >
            Type/Paste
          </button>
          <button
            onClick={() => setMode("upload")}
            className={`px-4 py-1 rounded-md border shadow-md text-sm ${
              mode === "upload"
                ? "bg-[#217C6A] text-white border-[#217C6A]"
                : "bg-white text-gray-700 border-gray-300"
            }`}
          >
            Upload File
          </button>
        </div>

        {mode === "paste" ? (
          <textarea
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder="Paste your CV content here or describe your background, education, skills, and experience..."
            className="w-full text-black border border-white h-60 p-3 rounded-md  shadow-md focus:ring-1 focus:ring-[#217C6A] focus:outline-none"
          />
        ) : (
          <div
            onClick={handleUploadClick}
            className="w-full h-60 border-2 border-dashed  rounded-md flex flex-col items-center justify-center cursor-pointer hover:bg-gray-100 transition"
          >
            <Upload className="h-10 w-10 text-gray-500 mb-2" />
            {fileName ? (
              <span className="text-sm text-gray-700">{fileName}</span>
            ) : (
              <span className="text-sm text-gray-500">
                Upload your CV file (PDF or doc format)
              </span>
            )}
            <input
              id="hiddenFileInput"
              type="file"
              onChange={handleFileChange}
              className="hidden"
            />
          </div>
        )}

        <button
          onClick={() => onAnalyze(text)}
          className="w-full mt-4 bg-[#217C6A] hover:bg-[#195d50] text-white font-semibold py-3 rounded-md transition"
        >
          Analyze My CV
        </button>
      </div>
    </div>
  );
}
