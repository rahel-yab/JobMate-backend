import type React from "react";
import { LanguageProvider } from "@/providers/language-provider";
import ReduxProvider from "@/providers/ReduxProvider";
import Nav from "../components/Nav/Nav";

export const metadata = {
  title: "JobMate - Your AI Career Buddy",
  description:
    "AI-powered career assistant for Ethiopian youth - CV feedback, job matching, and interview practice",
  generator: "v0.app",
};

export default function ChatLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <ReduxProvider>
      <LanguageProvider>
        <Nav />
        <main className="flex-1 overflow-auto ml-16">{children}</main>
      </LanguageProvider>
    </ReduxProvider>
  );
}
