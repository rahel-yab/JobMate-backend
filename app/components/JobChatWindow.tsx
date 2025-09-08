"use client";
import { ArrowLeft, Globe } from "lucide-react";
import { useLanguage } from "@/providers/language-provider";
import ChatInput from "./ChatInput";
import Card from "./jobSearch/Jobcard";
import { useRouter } from "next/navigation";

interface JobCardProps {
  id?: string;
  title?: string;
  company?: string;
  location?: string;
  type?: string;
  requirements?: string[];
  link?: string;
  source?: string;
}

export interface Message {
  id?: string | number;
  type?: "text" | "jobs";
  text?: string;
  jobs?: JobCardProps[];
}

export default function JobChatWindow({
  messages,
  input,
  setInput,
  onSend,
  renderMessage,
  onBack,
}: {
  messages: Message[];
  input: string;
  setInput: (val: string) => void;
  onSend: () => void;
  renderMessage: (msg: Message) => React.ReactNode;
  onBack?: () => void;
}) {
  const { language, setLanguage, t } = useLanguage();
  const router = useRouter();
  const hanldelBack = () => {
    router.push("/dashboard");
  };

  return (
    <div className="flex flex-col w-full h-screen bg-white">
      {/* Header */}
      <div className="flex items-center justify-between h-[80px] shadow px-4 bg-[#E6FFFA] text-black">
        <div className="flex items-center gap-3">
          <ArrowLeft
            className="h-5 w-5 text-black cursor-pointer"
            onClick={hanldelBack}
          />
          <div className="h-10 w-10 bg-[#00735B] text-white rounded-full flex items-center justify-center font-bold">
            JM
          </div>
          <div>
            <span className="font-semibold text-lg block text-black">
              {t("appTitle")}
            </span>
            <span className="text-sm font-light  text-black">
              {t("appSubtitle")}
            </span>
          </div>
        </div>

        <div className="flex items-center bg-white rounded-md shadow-md px-2 gap-1 py-1">
          <button onClick={() => setLanguage(language === "en" ? "am" : "en")}>
            <Globe className="h-5 w-5 text-[#00735B]" />
          </button>
          <p className="text-black font-bold text-sm">
            {language === "en" ? t("switchToAmharic") : "EN"}
          </p>
        </div>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {messages.map((msg) => {
          if (msg.type === "text") return renderMessage(msg);

          if (msg.type === "jobs" && msg.jobs) {
            return (
              <div key={msg.id} className="space-y-2">
                {msg.jobs.map((job, idx) => (
                  <Card
                    key={`${msg.id}-${idx}`}
                    id={String(idx)}
                    title={job.title}
                    company={job.company}
                    location={job.location}
                    type={job.type}
                    requirements={job.requirements}
                    link={job.link}
                    source={job.source}
                  />
                ))}
              </div>
            );
          }
        })}
      </div>

      {/* Input Area */}
      <div className="px-4 py-4 bg-[#BEE3DC] text-black justify-center">
        {/* {<QuickActions />} */}
        <ChatInput input={input} setInput={setInput} onSend={onSend} />
      </div>
    </div>
  );
}
