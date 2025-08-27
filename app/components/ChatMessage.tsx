type Props = {
  text: string;
  sender: "user" | "ai";
};

export default function ChatMessage({ text, sender }: Props) {
  const isUser = sender === "user";

  return (
    <div className={`flex ${isUser ? "justify-end" : "justify-start"}`}>
      <div
        className={`px-4 py-2 rounded-2xl max-w-[70%] ${
          isUser ? "bg-blue-500 text-white" : "bg-gray-200 text-black"
        }`}
      >
        {text}
      </div>
    </div>
  );
}
