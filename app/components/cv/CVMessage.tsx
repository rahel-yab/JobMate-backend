"use client";
import { SkillGap } from "@/lib/types/chat";

import {
  CheckCircle,
  ThumbsUp,
  AlertTriangle,
  Lightbulb,
  Wrench,
} from "lucide-react";

type SkillGap = {
  skillName: string;
  currentLevel: number;
  recommendedLevel: number;
  importance: string;
  improvementSuggestions: string;
};

type CVMessageProps = {
  summary: string;
  strengths: string;
  weaknesses: string;
  improvements: string;
  skillGaps?: SkillGap[] | null;
};

export default function CVMessage({
  summary,
  strengths,
  weaknesses,
  improvements,
  skillGaps,
}: CVMessageProps) {
  const normalizedSkillGaps = skillGaps ?? [];

  return (
    <div className="flex items-start gap-3 max-w-[80%]">
      {/* Placeholder avatar (like chat bubble style) */}
      <div className="h-7 w-7 p-3 text-white rounded-full flex items-center justify-center font-bold flex-shrink-0 text-xs"></div>

      {/* Main content */}
      <div className="bg-[#E6FFFA] shadow rounded-xl p-6 space-y-6 flex-1">
        {/* Header */}
        <h2 className="text-lg font-bold text-gray-800 flex items-center gap-2">
          <CheckCircle className="text-green-600 w-5 h-5" />
          CV Analysis Complete
          <span className="text-sm text-gray-500 ml-auto">AI Analysis</span>
        </h2>

        {/* Strengths */}
        <div className="bg-green-50 border-l-4 border-green-500 p-4 rounded-md">
          <h3 className="flex items-center gap-2 font-semibold text-green-700 mb-1">
            <ThumbsUp className="w-4 h-4 text-green-600" />
            Strengths
          </h3>
          <p className="text-gray-700 text-sm">{strengths}</p>
        </div>

        {/* Weaknesses / Areas for Improvement */}
        <div className="bg-red-50 border-l-4 border-red-500 p-4 rounded-md">
          <h3 className="flex items-center gap-2 font-semibold text-red-700 mb-1">
            <AlertTriangle className="w-4 h-4 text-red-600" />
            Areas for Improvement
          </h3>
          <p className="text-gray-700 text-sm">{weaknesses}</p>
        </div>

        {/* Improvement Suggestions */}
        <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded-md">
          <h3 className="flex items-center gap-2 font-semibold text-blue-700 mb-1">
            <Lightbulb className="w-4 h-4 text-blue-600" />
            Improvement Suggestions
          </h3>
          <p className="text-gray-700 text-sm">{improvements}</p>
        </div>

        {/* Skill Gaps */}
        {normalizedSkillGaps.length > 0 && (
          <div className="bg-purple-50 border-l-4 border-purple-500 p-4 rounded-md">
            <h3 className="flex items-center gap-2 font-semibold text-purple-700 mb-2">
              <Wrench className="w-4 h-4 text-purple-600" />
              Skill Gaps Identified
            </h3>
            <ul className="list-disc pl-5 space-y-3 text-sm text-gray-700">
              {normalizedSkillGaps.map((gap, idx) => (
                <li key={idx} className="flex flex-col">
                  <span className="font-semibold">{gap.skillName}</span>
                  <span className="text-xs text-gray-600">
                    Current: {gap.currentLevel}, Recommended:{" "}
                    {gap.recommendedLevel}
                  </span>
                  <span
                    className={`mt-1 px-2 py-0.5 text-xs w-fit rounded-md font-medium ${
                      gap.importance === "important"
                        ? "bg-red-100 text-red-700"
                        : "bg-yellow-100 text-yellow-700"
                    }`}
                  >
                    {gap.importance === "important" ? "Important" : "Optional"}
                  </span>
                  <p className="mt-1 text-gray-700">
                    {gap.improvementSuggestions}
                  </p>
                </li>
              ))}
            </ul>
          </div>
        )}
      </div>
    </div>
  );
}
