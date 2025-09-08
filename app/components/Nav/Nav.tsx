"use client";

import { useState, useEffect } from "react";
import NavItem from "./NavItem";
import { Jaro } from "next/font/google";
import { FiFileText, FiBriefcase, FiUser } from "react-icons/fi";
import { AiOutlineRead } from "react-icons/ai";
import { ChevronLeft, ChevronRight } from "lucide-react";
// import { useRouter } from "next/navigation";
import { useLogout } from "@/lib/redux/hooks/useLogout";

const jaro = Jaro({
  subsets: ["latin"],
  weight: ["400"],
});

const Nav = () => {
  const [isOpen, setIsOpen] = useState(false);
  // const router = useRouter();
  const logout = useLogout();

  const handleLogout = () => {
    logout(); // clears tokens, resets state, redirects
  };
  // ensure client and server match, then open
  useEffect(() => setIsOpen(false), []);

  const toggleSidebar = () => setIsOpen(!isOpen);

  return (
    <div
      className={`fixed top-0 left-0 h-screen bg-white shadow-lg transition-all duration-300 z-40
        ${isOpen ? "w-60" : "w-16"}`}
    >
      {/* Header */}
      <div className="mt-6 px-4 flex items-center justify-between">
        {isOpen && (
          <h1 className={`${jaro.className} 2xl:text-3xl text-2xl`}>
            <span className="font-jaro text-[#217C6A]">Job</span>Mate
          </h1>
        )}
        <button
          onClick={toggleSidebar}
          className="text-[#2CA58D] hover:text-[#217C6A] transition ml-auto"
        >
          {isOpen ? <ChevronLeft size={20} /> : <ChevronRight size={20} />}
        </button>
      </div>
      <hr className="mt-4 text-gray-200" />

      {/* Nav Items */}
      <div className="mt-6 flex flex-col gap-4">
        <NavItem
          href="/chat/cv"
          icon={<FiFileText className="text-[#114b0a]" />}
          label={isOpen ? "CV Feedback" : ""}
        />
        <NavItem
          href="/chat/jobsearch"
          icon={<FiBriefcase className="text-[#114b0a]" />}
          label={isOpen ? "Available Job" : ""}
        />
        <NavItem
          href="/interview"
          icon={<FiUser className="text-[#114b0a]" />}
          label={isOpen ? "Interview Practice" : ""}
        />
        <NavItem
          href="/offline_tips"
          icon={<AiOutlineRead className="text-[#114b0a]" />}
          label={isOpen ? "Offline Resources" : ""}
        />
      </div>
      {isOpen && (
        <div className="px-4 py-4 mt-auto">
          <button
            onClick={handleLogout}
            className="px-3 py-1 text-sm border border-red-500 text-red-600 rounded-md hover:bg-red-50 transition w-full"
          >
            Sign Out
          </button>
        </div>
      )}
    </div>
  );
};

export default Nav;
