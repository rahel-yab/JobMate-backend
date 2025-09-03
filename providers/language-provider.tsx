"use client";
import type React from "react";
import { createContext, useContext, useEffect, useState } from "react";

type Language = "en" | "am";

interface LanguageContextType {
  language: Language;
  setLanguage: (lang: Language) => void;
  t: (key: string) => string;
}

const LanguageContext = createContext<LanguageContextType | undefined>(
  undefined
);

const translations = {
  en: {
    // Header
    appTitle: "JobMate",
    appSubtitle: "Your AI Career Buddy",
    switchToAmharic: "አማ",

    // Welcome message
    welcomeMessage:
      "Hello! I'm JobMate, your AI career buddy. I'm here to help Ethiopian youth like you with CV feedback, job opportunities, and interview practice. How can I assist you today?",
  },
  am: {
    // Header
    appTitle: "JobMate",
    appSubtitle: "የእርስዎ AI ሙያ ጓደኛ",
    switchToAmharic: "En",

    // Welcome message
    welcomeMessage:
      "ሰላም! እኔ JobMate ነኝ፣ የእርስዎ AI ሙያ ጓደኛ። እንደ እርስዎ ላሉ የኢትዮጵያ ወጣቶች CV ግብረመልስ፣ የስራ እድሎች እና የቃለ መጠይቅ ልምምድ ለመስጠት እዚህ ነኝ። ዛሬ እንዴት ልረዳዎት እችላለሁ?",
  },
};

export function LanguageProvider({ children }: { children: React.ReactNode }) {
  const [language, setLanguageState] = useState<Language>("en");
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    const savedLanguage = localStorage.getItem("jobmate-language") as Language;
    console.log(savedLanguage);
    if (savedLanguage && (savedLanguage === "en" || savedLanguage === "am")) {
      setLanguageState(savedLanguage);
    }
    setMounted(true);
  }, []);

  const setLanguage = (lang: Language) => {
    setLanguageState(lang);
    localStorage.setItem("jobmate-language", lang);
    document.documentElement.lang = lang === "am" ? "am" : "en";
  };

  const t = (key: string): string => {
    return (
      translations[language][
        key as keyof (typeof translations)[typeof language]
      ] || key
    );
  };

  if (!mounted) {
    return null;
  }

  return (
    <LanguageContext.Provider value={{ language, setLanguage, t }}>
      {/*    <div className={language === "am" ? "font-ethiopic" : "font-sans"}> */}
      <div className="font-sans">{children}</div>
    </LanguageContext.Provider>
  );
}

export function useLanguage() {
  const context = useContext(LanguageContext);
  if (context === undefined) {
    throw new Error("useLanguage must be used within a LanguageProvider");
  }
  return context;
}
