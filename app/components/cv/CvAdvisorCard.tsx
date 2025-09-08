"use client";

import { Lightbulb } from "lucide-react";
import { useRouter } from "next/navigation";

export default function CvAdvisorCard() {
  const router = useRouter();

  const handleStart = () => {
    router.push("/course");
  };

  return (
    <div className="bg-[#E0F3F1] rounded-2xl p-6 mb-6 shadow-md transition-shadow hover:shadow-lg h-full flex flex-col">
      {/* Title with icon */}
      <div className="flex items-center gap-2 mb-3">
        <Lightbulb className="h-6 w-6 text-[#1F9D8A]" />
        <h2 className="font-bold text-lg text-gray-800">
          Get Course Suggestions
        </h2>
      </div>

      {/* Description */}
      <p className="text-gray-600 mb-6 text-sm">
        Discover tailored online courses and general tips based on your last CV
        analysis.
      </p>

      {/* Button */}
      <button
        onClick={handleStart}
        className="mt-auto w-full bg-[#1F9D8A] text-white font-semibold py-3 rounded-md hover:bg-[#187967] transition"
      >
        View Suggestions
      </button>
    </div>
  );
}
