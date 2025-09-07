"use client"
import ChatWindow from "./ChatWindow"
import { useLanguage } from "@/providers/language-provider";
import { ArrowLeft, Globe } from "lucide-react";
import Link from "next/link";
import {useState} from "react"
export default function Header(){
    const { language, setLanguage, t } = useLanguage();
    return (
      <div className="flex items-center sticky z-1000 top-0 justify-between h-[80px] shadow px-4 bg-[#217C6A] text-white w-full">
        <div className="flex items-center gap-3">
          <Link href="/dashboard"><ArrowLeft className="h-5 w-5 text-white cursor-pointer" /></Link>
          <div className="h-10 w-10 bg-[#0F3A31] text-white rounded-full flex items-center justify-center font-bold">
            JM
          </div>
          <div>
            <span className="font-semibold text-lg block">{t("appTitle")}</span>
            <span className="text-sm text-white/70">{t("appSubtitle")}</span>
          </div>
        </div>
        <div className="flex items-center bg-white rounded-md shadow-md px-2 gap-1 py-1">
          <button className = "cursor-pointer flex gap-1 items-center" onClick={() => setLanguage(language === "en" ? "am" : "en")}>
            <Globe className="h-4 w-4 text-[#0F3A31]" /> 
             <span className="text-black font-bold text-sm">
            {language === "en" ? t("switchToAmharic") : "EN"}
          </span>
          </button>
        </div>
      </div>

    )
}