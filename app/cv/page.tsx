"use client";

import { ArrowLeft } from "lucide-react";
import Link from "next/link";
import { useEffect, useState } from "react";
import CvIntroCard from "@/app/components/cv/CvIntroCard";
import CvBenefitsCard from "@/app/components/cv/CvBenefitsCard";
import CvHistoryCard from "@/app/components/cv/CvHistoryCard";
import { useGetUserChatsQuery } from "@/lib/redux/api/cvApi";
import CvExistingChat from "@/app/components/cv/CvExistingChat";
import CvAdvisorCard from "../components/cv/CvAdvisorCard";

export default function CvPage() {
  const { data: chats = [], isLoading, refetch } = useGetUserChatsQuery();
  const [selectedChat, setSelectedChat] = useState<string | null>(null);

  // On mount, check if there's a persisted chatId in sessionStorage
  useEffect(() => {
    const storedChatId = sessionStorage.getItem("selected_chat_id");
    if (storedChatId) {
      setSelectedChat(storedChatId);
    }
  }, []);

  // Persist chatId whenever it changes
  useEffect(() => {
    if (selectedChat) {
      sessionStorage.setItem("selected_chat_id", selectedChat);
    } else {
      sessionStorage.removeItem("selected_chat_id");
    }
  }, [selectedChat]);

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
    <div className="min-h-screen bg-gradient-to-b from-green-50 to-blue-50 flex flex-col items-center py-10">
      <div className="w-full max-w-4xl px-6 space-y-8">
        {/* Back to Dashboard */}
        <Link
          href="/dashboard"
          className="inline-flex items-center gap-2 text-gray-700 hover:bg-gray-100 px-4 py-2 rounded-lg transition shadow-sm bg-white"
        >
          <ArrowLeft className="h-5 w-5" />
          <span className="font-medium">Dashboard</span>
        </Link>

        {/* Intro and Benefits Cards */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <CvIntroCard />
          <CvAdvisorCard />
        </div>

        {/* Chat history preview */}
        {isLoading ? (
          <div className="bg-white rounded-2xl p-8 shadow-md border border-gray-200 text-center text-gray-500">
            Loading chat history...
          </div>
        ) : (
          <CvHistoryCard history={chats} onSelectChat={setSelectedChat} />
        )}
      </div>
    </div>
  );
}
