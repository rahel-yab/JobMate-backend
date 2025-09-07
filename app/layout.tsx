import type React from "react";
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
          <LanguageProvider>
            <ProtectedWrapper>{children}</ProtectedWrapper>
            <Toaster position="top-right" reverseOrder={false} />
          </LanguageProvider>
        </ReduxProvider>
      </body>
    </html>
  );
}
