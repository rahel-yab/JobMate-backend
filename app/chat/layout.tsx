import type React from "react";
import type { Metadata } from "next";
import { GeistSans } from "geist/font/sans";
import { Noto_Sans_Ethiopic } from "next/font/google";
import { LanguageProvider } from "@/providers/language-provider";
import ReduxProvider from "@/providers/ReduxProvider";
import Nav from "../components/Nav/Nav";

const notoSansEthiopic = Noto_Sans_Ethiopic({
  subsets: ["ethiopic"],
  display: "swap",
  variable: "--font-ethiopic",
});

export const metadata: Metadata = {
  title: "JobMate - Your AI Career Buddy",
  description:
    "AI-powered career assistant for Ethiopian youth - CV feedback, job matching, and interview practice",
  generator: "v0.app",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${GeistSans.variable} ${notoSansEthiopic.variable}`}
    >
      <body className="bg-gray-50">
        <ReduxProvider>
          <LanguageProvider>
            <Nav />
            <main className="flex-1 overflow-auto ml-16">{children}</main>
          </LanguageProvider>
        </ReduxProvider>
      </body>
    </html>
  );
}
