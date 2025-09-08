import { Message } from "./ChatWindow";
export default function ChatMessage({ message }: { message: Message }) {
  const isUser = message.sender === "user";

  return (
    <div className={`flex  ${isUser ? "justify-end" : "justify-start"} mb-3`}>
      {isUser ? (
        <div className="bg-[#28957F] text-white px-6 py-4 rounded-2xl max-w-[70%] shadow">
          <span className="block">{message.text}</span>
          <span className="text-xs opacity-70 block text-right mt-2">
            {message.time}
          </span>
        </div>
      ) : (
        <div className="flex items-start gap-3 max-w-[80%] ">
          <div className="h-7 w-7 p-3 bg-[#00735A] text-white rounded-full flex items-center justify-center font-bold flex-shrink-0 text-xs">
            JM
          </div>
          <div className="bg-[#E6FFFA] text-black px-6 py-4 rounded-2xl flex-1 shadow">
            {message.text}
            <span className="text-xs opacity-70 block text-left mt-2">
              {message.time}
            </span>
          </div>
        </div>
      )}
    </div>
  );
}
