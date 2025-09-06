"use client";

import { Clock, MessageCircle } from "lucide-react";

interface CvHistoryCardProps {
  history: any[];
  onSelectChat: (chatId: string) => void;
}

export default function CvHistoryCard({
  history,
  onSelectChat,
}: CvHistoryCardProps) {
  // Filter chats to only include those with at least one assistant message
  const chatsWithAssistant = history.filter(
    (h) =>
      Array.isArray(h.messages) &&
      h.messages.some((m: any) => m.role === "assistant")
  );

  return (
    <div className="bg-white rounded-2xl p-6 shadow-md border border-gray-200">
      {/* Header */}
      <div className="flex items-center gap-2 mb-3">
        <Clock className="h-5 w-5 text-[#217C6A]" />
        <h3 className="font-semibold text-lg text-gray-800">Chat History</h3>
      </div>
      <p className="text-sm text-gray-500 mb-5">
        Review or continue your past CV chats
      </p>

      {/* Empty state */}
      {chatsWithAssistant.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-10 text-center">
          <MessageCircle className="h-12 w-12 text-gray-300 mb-3" />
          <p className="text-gray-600 font-medium">No chat history yet</p>
          <p className="text-sm text-gray-400 mt-1">
            Start your first CV analysis above
          </p>
        </div>
      ) : (
        // Scrollable container
        <div className="space-y-3 max-h-[400px] overflow-y-auto pr-2">
          {chatsWithAssistant
            .slice()
            .sort(
              (a, b) =>
                new Date(b.updated_at).getTime() -
                new Date(a.updated_at).getTime()
            ) // ✅ sort by updated_at (newest first)
            .map((h) => {
              const firstAiMsg = h.messages.find(
                (m: any) => m.role === "assistant"
              );

              return (
                <div
                  key={h.chat_id}
                  className="p-4 bg-[#F9FAFB] border border-gray-100 rounded-xl cursor-pointer hover:shadow-sm hover:bg-gray-50 transition"
                  onClick={() => onSelectChat(h.chat_id)}
                >
                  <div className="flex justify-between items-center mb-2">
                    <span className="text-xs text-gray-400">
                      {new Date(h.updated_at).toLocaleDateString(undefined, {
                        year: "numeric",
                        month: "short",
                        day: "numeric",
                      })}
                    </span>
                  </div>

                  <p className="text-sm text-gray-600 line-clamp-2">
                    💬 {firstAiMsg.content}
                  </p>
                </div>
              );
            })}
        </div>
      )}
    </div>
  );
}
