"use client";
import React from "react";
import { Button } from "./ui/Button";
import { Jaro } from "next/font/google";
import { useLanguage } from "@/providers/language-provider";
import { Globe } from "lucide-react";
import Link from "next/link";
import { useRouter } from "next/navigation";

const jaro = Jaro({
  subsets: ["latin"],
  weight: ["400"],
});

const NavBar = () => {
  const { language, setLanguage, t } = useLanguage();
  const router = useRouter();
  return (
    <div className="fixed top-0 left-0 w-full z-50 bg-[#f6f6f6] flex justify-around items-center py-3">
      <Link href="#home">
        <h1 className={`${jaro.className} 2xl:text-3xl text-2xl`}>
          <span className="font-jaro text-[#217C6A]">Job</span>Mate
        </h1>
      </Link>
      <div className="flex">
        <a href="#home" className="px-4">
          {t("home")}
        </a>
        <a href="#service" className="px-4">
          {t("service")}
        </a>
      </div>
      <div className="flex gap-3 items-center">
        <p onClick={() => router.push("/login")}>{t("login")}</p>
        <Button
          className="bg-[#2CA58D] text-white px-4"
          onClick={() => router.push("/register")}
        >
          {t("signUp")}
        </Button>
        <div
          className="flex items-center bg-white rounded-md shadow-md px-2 gap-1 py-1"
          onClick={() => setLanguage(language === "en" ? "am" : "en")}
        >
          <button>
            <Globe className="h-5 w-5 text-[#0F3A31]" />
          </button>
          <p className="text-black font-bold text-sm">
            {language === "en" ? t("switchToAmharic") : "EN"}
          </p>
        </div>
      </div>
    </div>
  );
};

export default NavBar;
