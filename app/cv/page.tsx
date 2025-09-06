// "use client";

// import { ArrowLeft } from "lucide-react";
// import Link from "next/link";
// import { useState } from "react";
// import CvIntroCard from "@/app/components/cv/CvIntroCard";
// import CvBenefitsCard from "@/app/components/cv/CvBenefitsCard";
// import CvHistoryCard from "@/app/components/cv/CvHistoryCard";
// import { useGetUserChatsQuery } from "@/lib/redux/api/cvApi";

// export default function CvPage() {
//   const { data: chats = [], isLoading } = useGetUserChatsQuery();
//   const [selectedChat, setSelectedChat] = useState<string | null>(null);

//   return (
//     <div className="min-h-screen bg-[#F0F8FA]">
//       <div className="max-w-2xl mx-auto py-8 px-4 space-y-6">
//         {/* Back to Home */}
//         <Link
//           href="/"
//           className="inline-flex items-center gap-2 text-gray-700 hover:bg-gray-100 px-3 py-2 rounded-md transition"
//         >
//           <ArrowLeft className="h-5 w-5" />
//           <span className="font-medium">Home</span>
//         </Link>

//         {/* Cards */}
//         <CvIntroCard />
//         <CvBenefitsCard />

//         {/* Chat history preview */}
//         {isLoading ? (
//           <div className="bg-white rounded-2xl p-6 shadow-md border border-gray-200 text-center text-gray-500">
//             Loading chat history...
//           </div>
//         ) : (
//           <CvHistoryCard history={chats} onSelectChat={setSelectedChat} />
//         )}

//         {/* View full history */}
//         <Link
//           href="/cv/history"
//           className="block text-center text-[#217C6A] font-medium mt-2 hover:underline"
//         >
//           View full history →
//         </Link>
//       </div>
//     </div>
//   );
// }

"use client";

import { ArrowLeft } from "lucide-react";
import Link from "next/link";
import { useState } from "react";
import CvIntroCard from "@/app/components/cv/CvIntroCard";
import CvBenefitsCard from "@/app/components/cv/CvBenefitsCard";
import CvHistoryCard from "@/app/components/cv/CvHistoryCard";
import { useGetUserChatsQuery } from "@/lib/redux/api/cvApi";
import CvExistingChat from "@/app/components/cv/CvExistingChat";

export default function CvPage() {
  const { data: chats = [], isLoading, refetch } = useGetUserChatsQuery();
  const [selectedChat, setSelectedChat] = useState<string | null>(null);

  if (selectedChat) {
    return (
      <CvExistingChat
        chatId={selectedChat}
        onBack={() => {
          setSelectedChat(null);
          refetch();
        }}
      />
    );
  }

  return (
    <div className="min-h-screen bg-[#F0F8FA]">
      <div className="max-w-2xl mx-auto py-8 px-4 space-y-6">
        {/* Back to Home */}
        <Link
          href="/"
          className="inline-flex items-center gap-2 text-gray-700 hover:bg-gray-100 px-3 py-2 rounded-md transition"
        >
          <ArrowLeft className="h-5 w-5" />
          <span className="font-medium">Home</span>
        </Link>

        {/* Cards */}
        <CvIntroCard />
        <CvBenefitsCard />

        {/* Chat history preview */}
        {isLoading ? (
          <div className="bg-white rounded-2xl p-6 shadow-md border border-gray-200 text-center text-gray-500">
            Loading chat history...
          </div>
        ) : (
          <CvHistoryCard history={chats} onSelectChat={setSelectedChat} />
        )}

        {/* View full history */}
        <Link
          href="/cv/history"
          className="block text-center text-[#217C6A] font-medium mt-2 hover:underline"
        >
          View full history →
        </Link>
      </div>
    </div>
  );
}
