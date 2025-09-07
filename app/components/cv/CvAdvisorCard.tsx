"use client";

import { Lightbulb } from "lucide-react";
import { useRouter } from "next/navigation";

export default function CvAdvisorCard() {
  const router = useRouter();

  const handleStart = () => {
    router.push("/course");
  };

  return (
    <div className="bg-white rounded-2xl p-6 shadow-md border border-gray-200 transition hover:shadow-lg h-full flex flex-col">
      <div className="flex items-center gap-2 mb-3">
        <Lightbulb className="h-6 w-6 text-blue-600" />
        <h2 className="font-bold text-lg text-gray-800">
          Get Career Suggestions
        </h2>
      </div>

      <p className="text-gray-600 mb-6 text-sm">
        Discover tailored online courses and career tips designed to strengthen
        your skills and guide your professional growth.
      </p>

      <button
        onClick={handleStart}
        className="mt-auto w-full bg-blue-600 text-white font-semibold py-3 rounded-md hover:bg-blue-700 transition"
      >
        View Suggestions
      </button>
    </div>
  );
}
