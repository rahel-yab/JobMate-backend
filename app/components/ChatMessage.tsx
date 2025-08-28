type Props = { text: string; sender: string; time: string };

export default function ChatMessage({ text, sender, time }: Props) {
  const isUser = sender === "user";

  return (
    <div className={`flex  ${isUser ? "justify-end" : "justify-start"} mb-3`}>
      {isUser ? (
        <div className="bg-[#28957F] text-white  px-6 py-4  rounded-2xl max-w-[70%]">
          <span className="block">{text}</span>
          <span className="text-xs opacity-70 block text-right mt-2">
            {time}
          </span>
        </div>
      ) : (
        <div className="flex items-start gap-3 max-w-[80%]">
          <div className="h-7 w-7 p-3 bg-[#0F3A31] text-white rounded-full flex items-center justify-center font-bold flex-shrink-0">
            JM
          </div>
          <div className="bg-[#BEE3DC] text-black px-6 py-4 rounded-2xl flex-1">
            <span className="block">{text}</span>
            <span className="text-xs opacity-70 block text-left mt-2">
              {time}
            </span>
          </div>
        </div>
      )}
    </div>
  );
}
