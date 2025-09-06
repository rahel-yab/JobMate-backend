"use client";

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
  skillGaps?: SkillGap[];
};

export default function CVMessage({
  summary,
  strengths,
  weaknesses,
  improvements,
  skillGaps = [],
}: CVMessageProps) {
  return (
    <div className="flex items-start gap-3 max-w-[80%]">
      <div className="h-7 w-7 p-3 text-white rounded-full flex items-center justify-center font-bold flex-shrink-0 text-xs"></div>

      <div className="bg-[#DFF2EE] text-black px-6 py-4 rounded-2xl flex-1 shadow">
        <div className="space-y-3">
          <h3 className="font-bold text-[#217C6A]">📄 CV Analysis</h3>

          <div>
            <p className="font-semibold">Summary:</p>
            <p className="text-sm text-gray-700">{summary}</p>
          </div>

          <div>
            <p className="font-semibold">✅ Strengths:</p>
            <ul className="list-disc pl-5 text-sm text-gray-700">
              <li>{strengths}</li>
            </ul>
          </div>

          <div>
            <p className="font-semibold">⚠️ Weaknesses:</p>
            <ul className="list-disc pl-5 text-sm text-gray-700">
              <li>{weaknesses}</li>
            </ul>
          </div>

          <div>
            <p className="font-semibold">💡 Improvements:</p>
            <ul className="list-disc pl-5 text-sm text-gray-700">
              <li>{improvements}</li>
            </ul>
          </div>

          {skillGaps.length > 0 && (
            <div>
              <p className="font-semibold">🛠 Skill Gaps:</p>
              <ul className="list-disc pl-5 text-sm text-gray-700 space-y-1">
                {skillGaps.map((gap, idx) => (
                  <li key={idx} className="flex flex-col">
                    <div>
                      <strong>{gap.skillName}</strong> (Current:{" "}
                      {gap.currentLevel}, Recommended: {gap.recommendedLevel})
                    </div>
                    <div
                      className={`text-xs font-semibold mt-1 px-2 py-0.5 w-fit rounded-md ${
                        gap.importance === "important"
                          ? "bg-red-100 text-red-700"
                          : "bg-yellow-100 text-yellow-700"
                      }`}
                    >
                      {gap.importance === "important"
                        ? "Important"
                        : "Optional"}
                    </div>
                    <div className="text-sm text-gray-700 mt-1">
                      {gap.improvementSuggestions}
                    </div>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
