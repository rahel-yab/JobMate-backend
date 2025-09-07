import { useState ,  useEffect } from "react";
import { useLanguage } from "@/providers/language-provider";
interface TipProviderProps {
  tips: string[][];
}
export default function TipProvider({ tips }: TipProviderProps) {
  const {t} = useLanguage();
  const [page, setPage] = useState<number>(0);
  const tipsPerPage = 4, totalTips = tips[1].length, totalPages = Math.ceil(totalTips / tipsPerPage);
  const startIndex = page * tipsPerPage, endIndex = startIndex + tipsPerPage;
  const currentTips = tips[1].slice(startIndex, endIndex), initialNumber = 1;
  useEffect(() => {    setPage(0);  }, [tips]);
  return (
    <div className="bg-white p-6 rounded-2xl  max-w-3xl mx-auto space-y-8">
      <h2 className="text-4xl font-extrabold text-[#217C6A] text-center">
        {tips[0]}
      </h2>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
        {currentTips.map((insight, index) => {
          const badgeNumber = initialNumber + startIndex + index; 
          return (
            <div
              key={index}
              className="flex items-start gap-4 p-4 bg-cyan-50 rounded-xl 
              shadow-md hover:scale-102 transform transition-transform duration-100">
              <div className="flex-shrink-0 w-6 h-6 bg-[#217C6A] text-white 
              font-bold rounded-full flex items-center justify-center">
                {badgeNumber}
              </div>
              <p className="text-gray-800">{insight}</p>
            </div>        );        })}
      </div>
      <div className="flex justify-center gap-4">
        <button
          onClick={() => setPage((prev) => Math.max(prev - 1, 0))}
          disabled={page === 0}
          className={`px-5 py-2 rounded-lg font-semibold text-white transition-colors ${
            page === 0 ? "bg-gray-400 cursor-not-allowed" : "bg-[#217C6A] hover:bg-[#1a5d50]"
          }`}>  {t("back")}
        </button>
        <button
          onClick={() => setPage((prev) => Math.min(prev + 1, totalPages - 1))}
          disabled={page === totalPages - 1}
          className={`px-5 py-2  rounded-lg font-semibold text-white transition-colors ${
            page === totalPages - 1 ? "bg-gray-400 cursor-not-allowed" : "bg-[#40756a] hover:bg-[#1a5d50]"
          }`}> {t("next")}
        </button>
      </div>
      <div className="p-6 bg-gradient-to-r bg-cyan-50 rounded-2xl shadow-lg border-l-4 border-[#217C6A]">
        <h3 className="font-bold text-[#217C6A] text-xl">{tips[2][0]}</h3>
        <p className="mt-2 text-gray-800">{tips[2][1]}</p>
      </div>
    </div>
  );
}
