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
    generalWelcomeMessage:
      "Hello! I’m JobMate, your AI career buddy. This space is for open conversation, ask questions, share ideas, or chat about your career journey",
    cvWelcomeMessage:
      "Great! I'd be happy to help you with your CV. You can upload your current CV or describe your background below, and I'll provide detailed feedback to help you improve it.",

    // offline tips
    cv_writing: "CV Writing",
    interview_prep: "Interview Prep",
    job_boards: "Job Boards",
    skill_enhancements: "Skill Enhancements",
    market_insights: "Market Insights",
    motivation: "Motivation",
    start_building: "Start building your AI powered CV",
    your_offline: "Your offline career resource",
    next: "Next",
    back: "Back",
    // login
    l_welcome: "Welcome Back",
    l_subtitle: "Sign in to continue your career journey",
    email: "Email Address",
    password: "Password",
    l_signIn: "Sign In",
    l_signingIn: "Signing In...",
    l_noAccount: "Don't have an account? ",
    l_register: "Sign up",
    l_forgotPassword: "Forgot password?",

    // register
    r_join: "Join JobMate",
    r_create: "Create your account to get started",
    r_fullName: "Full Name",
    r_createAccount: "Sign Up",
    r_noAccount: " Already have an account? ",
    r_login: "Sign in",
    // otp
    otp_title: "Verify OTP",
    otp_subtitle1: "We’ve sent an OTP to",
    otp_subtitle2: "Please enter it below to complete your registration.",
    otp_placeholder: "Enter OTP",
    otp_button: "Verify & Register",
    otp_verifying: "Verifying...",
    otp_failed: "Registration failed. Please try again.",
    //forgot and reset
    f_title: "Forgot Password?",
    emailPlaceholder: "Enter your email",
    cancel: "Cancel",
    sendOtp: "Send OTP",
    sending: "Sending...",
    reset_title: "Reset Password",
    resetBtn: "Reset Password",

    // Home Section
    home_title: "You don’t have to job-hunt alone",
    home_description:
      "Finding a job can feel overwhelming — from writing the perfect CV to preparing for tough interview questions. JobMate is your AI-powered career buddy, built for Ethiopian youth. It reviews your CV, highlights skills you need to grow, and suggests both local and remote opportunities. You can even practice real interview questions and get instant feedback, in Amharic or English. With JobMate by your side, you’ll gain the confidence and guidance you need to land your first role, grow your career, and unlock global opportunities.",
    register: "Register",

    // Services Section
    service_title: "JobMate Services",
    cv_feedback_title: "CV Feedback",
    cv_feedback_desc:
      "Get instant feedback on your CV, discover strengths, and identify areas to improve.",
    job_title: "Available Jobs",
    job_desc:
      "Find local, remote, and freelance opportunities tailored to your skills and goals.",
    interview_title: "Interview Practice",
    interview_desc:
      "Practice common interview questions with AI and get real-time feedback. Learn tips on salary negotiation, workplace culture, and more.",
    offline_title: "Offline Resources",
    offline_desc:
      "Even without internet, access stored interview tips, CV templates, and job search guides.",
    chat_title: "Chat Assistance",
    chat_desc:
      "Get quick answers to your questions through a friendly AI chat, making learning and problem-solving easier anytime.",

    // Footer
    footer_copyright: "Copyright © 2020 Nexcent ltd.",
    footer_rights: "All rights reserved",

    // NavBar
    home: "Home",
    service: "Service",
    login: "Log In",
    signUp: "Sign Up",
  },
  am: {
    // Header
    appTitle: "JobMate",
    appSubtitle: "የእርስዎ AI ሙያ ጓደኛ",
    switchToAmharic: "En",

    // Welcome message
    welcomeMessage:
      "ሰላም! እኔ JobMate ነኝ፣ የእርስዎ AI የሙያ ጓደኛ። እንደ እርስዎ ላሉ የኢትዮጵያ ወጣቶች CV ግብረመልስ፣ የስራ እድሎች እና የቃለ መጠይቅ ልምምድ ለመስጠት እዚህ ነኝ። ዛሬ እንዴት ልረዳዎት እችላለሁ?",
    generalWelcomeMessage:
      "ሰላም! እኔ JobMate ነኝ፣ የእርስዎ AI የሙያ ጓደኛ። ይህ ቦታ ለክፍት ውይይት ነው፤ ጥያቄዎችን ይጠይቁ፣ ሃሳቦችን ያካፍሉ፣ ወይም ስራዎ ላይ ያለውን ጉዞ ይወያዩ።",
    cvWelcomeMessage:
      "በጣም ጥሩ! በCVዎ ላይ ልረዳዎት ደስ ይለኛል። የአሁኑን CVዎን መስቀል ወይም ዳራዎን ከዚህ በታች መግለጽ ይችላሉ፣ እና እንዲያሻሽሉት ለመርዳት ዝርዝር ግብረመልስ እሰጣለሁ።",

    // offline tips
    cv_writing: "CV አጻጻፍ",
    interview_prep: "ቃለ መጠይቅ ዝግጅት ",
    job_boards: "የስራ ማስታወቂያ ሰሌዳዎች",
    skill_enhancements: "ክህሎትን ማሳደግ",
    market_insights: "የሥራ ገበያ ግንዛቤዎች",
    motivation: "ራስን ማንቃት",
    start_building: "AIን ተጠቅመው CV ያዘጋጁ",
    your_offline: "ካለ ኢንተርኔት ግንኙነት የሚያገኟቸው አገልግሎቶች",
    next: "ቀጣይ",
    back: "ተመለስ",
    // login
    l_welcome: "እንኳን በደህና መጡ",
    l_subtitle: "የሥራ ጉዞዎን ለመቀጠል ግባ",
    email: "ኢሜይል አድራሻ",
    password: "የይለፍ ቃል",
    l_signIn: "ግባ",
    l_signingIn: "በመግባት ላይ...",
    l_noAccount: "መለያ የለህም? አዲስ መለያ ፍጠር",
    l_register: "ተመዝገብ ",
    l_forgotPassword: "የይለፍ ቃል ረስተዋል?",

    // register
    r_join: "JobMate ጋር ተቀላቀል",
    r_create: "መለያህን ፍጠር እና ጀምር",
    r_fullName: "ሙሉ ስም",
    r_createAccount: "ተመዝገብ",
    r_haveAccount: "መለያ አለህ? ግባ",

    // otp
    otp_title: "ኦቲፒ ያረጋግጡ",
    otp_subtitle1: "ኦቲፒ ኮድ ወደ ",
    otp_subtitle2: "ተልኳል እባክዎ ምዝገባውን ለመጨረስ ከታች ባለው ላይ ኮዱን ያስገቡ",
    otp_placeholder: "ኦቲፒ ያስገቡ",
    otp_button: "ያረጋግጡ እና ይመዝገቡ",
    otp_verifying: "በመረጋገጥ ላይ...",
    otp_failed: "ምዝገባው አልተሳካም። እባክዎ ደግመው ይሞክሩ።",
    // forgot and reset
    f_title: "የይለፍ ቃል ረስተዋል?",
    emailPlaceholder: "ኢሜይል አስገባ",
    cancel: "ሰርዝ",
    sendOtp: "ኦቲፒ ላክ",
    sending: "በመላክ ላይ...",
    reset_title: "የይለፍ ቃልዎን ያድሱ",
    resetBtn: "የይለፍ ቃል አድስ",

    // Home Section
    home_title: "ብቻህን ስራ መፈልግ ግድ አደለም",
    home_description:
      "ስራ መፈለግ አስጨናቂ ሊሆን ይችላል — ከፍጹም የሆነ CV መጻፍ እስከ አስቸጋሪ ጥያቄዎች ለመለምከት። JobMate የAI ኃይል የተሞላ የሙያ ጓደኛ ነው፣ ለኢትዮጵያ ወጣቶች ተለዋዋጭ ተጠቃሚ። እርስዎን CV ይመረምራል፣ የሚያሻሽሉትን ክህሎቶች ይጠቁማል፣ እና አካባቢያዊና የርቀት ዕድሎችን ይጠቁማል። እንደ እውነተኛ የቃለመጠይቅ ጥያቄዎች ልምምድ ያድርጉ እና በፍጥነት ግብረመልስ ያግኙ፣ በአማርኛ ወይም በእንግሊዝኛ።",
    register: "ተመዝገብ",

    // Services Section
    service_title: "የJobMate አገልግሎቶች",
    cv_feedback_title: "CV ግብረመልስ",
    cv_feedback_desc:
      "በCVዎ ላይ ፈጣን ግብረመልስ ያግኙ፣ ጥሩ ነጥቦችን ይገነዘቡ፣ እና የሚሻሹበትን ቦታ ይወቁ።",
    job_title: "የስራ እድሎች",
    job_desc: "ከእርስዎ ክህሎት እና ዓላማ ጋር የሚዛመዱ አካባቢያዊ፣ የርቀት እና ነፃ ስራዎችን ያግኙ።",
    interview_title: "የቃለ መጠይቅ ልምምድ",
    interview_desc:
      "ተለመዱ የቃለመጠይቅ ጥያቄዎችን ከAI ጋር ይልማዱ እና በቅርብ ጊዜ ግብረመልስ ያግኙ። በደሞዝ እና የስራ ባህሪ ምክሮችን ያውቁ።",
    offline_title: "የኦፍላይን ሀብት",
    offline_desc:
      "እንኳን ከኢንተርኔት ባለመኖር፣ የቃለመጠይቅ ምክር፣ CV አብነቶች እና የስራ ፍለጋ መመሪያዎችን ያግኙ።",
    chat_title: "የቻት እርዳታ",
    chat_desc: "በአዳዲስ ጥያቄዎች ፍጥነት መልስ ለማግኘት ከAI ጋር ቀላል የሆነ የቻት እንቅስቃሴ ያግኙ።",

    // Footer
    footer_copyright: "Copyright © 2020 Nexcent ltd.",
    footer_rights: "All rights reserved",

    //NavBar
    home: "ዋና",
    service: "አገልግሎት",
    login: "ግባ",
    signUp: "ተመዝገብ",
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
      {children}
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
