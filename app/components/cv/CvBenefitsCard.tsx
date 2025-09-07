import { CheckCircle } from "lucide-react";

const benefits = [
  "Detailed CV feedback and analysis",
  "Skill gap identification",
  "Course suggestions to fill skill gaps",
  "Get interactive chat about your CV",
];

export default function CvBenefitsCard() {
  return (
    <div className="bg-white rounded-2xl p-6 mb-6 shadow-md border border-gray-100">
      <h3 className="font-bold text-lg text-gray-800 mb-4">What You'll Get</h3>

      {/* 1-column grid */}
      <div className="grid grid-cols-1 gap-y-4">
        {benefits.map((b, i) => (
          <div key={i} className="flex items-start gap-2 text-gray-700">
            <CheckCircle className="h-5 w-5 text-[#217C6A] shrink-0 mt-0.5" />
            <span>{b}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
