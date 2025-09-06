import type React from "react";
import type { Metadata } from "next";
import { GeistSans } from "geist/font/sans";
import { Noto_Sans_Ethiopic } from "next/font/google";
import { LanguageProvider } from "@/providers/language-provider";
import ReduxProvider from "../providers/ReduxProvider";
import "./globals.css";
import ProtectedWrapper from "./components/ProtectedWrapper";
import { Toaster } from "react-hot-toast";

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
      <head>
        <style>{`
html {
  font-family: ${GeistSans.style.fontFamily};
  --font-sans: ${GeistSans.variable};
  --font-ethiopic: ${notoSansEthiopic.variable};
}
        `}</style>
      </head>
      <body>
        <ReduxProvider>
          <LanguageProvider><ProtectedWrapper>{children}</ProtectedWrapper><Toaster position="top-right" reverseOrder={false} /></LanguageProvider>
        </ReduxProvider>
      </body>
    </html>
  );
}
