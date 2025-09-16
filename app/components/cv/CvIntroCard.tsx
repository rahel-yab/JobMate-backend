"use client";

import { FileText } from "lucide-react";
import { useRouter } from "next/navigation";

export default function CvIntroCard() {
  const router = useRouter();

  const handleStart = () => {
    router.push("/chat/cv");
  };

  return (
    <div className="bg-[#DFF2EE] rounded-2xl p-6 mb-6 shadow-md transition-shadow hover:shadow-lg">
      <div className="flex items-center gap-2 mb-3">
        <FileText className="h-6 w-6 text-[#217C6A]" />
        <h2 className="font-bold text-lg text-gray-800">Analyze Your CV</h2>
      </div>

      <p className="text-gray-600 mb-6">
        Upload or paste your CV to get detailed analysis and start chatting
        about it.
      </p>

      <button
        onClick={handleStart}
        className="w-full bg-[#217C6A] text-white font-semibold py-3 rounded-md hover:bg-[#195d50] transition"
      >
        Start CV Analysis
      </button>
    </div>
  );
}
