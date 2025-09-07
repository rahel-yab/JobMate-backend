"use client";

import { useState, useEffect } from "react";
import NavItem from "./NavItem";
import { Jaro } from "next/font/google";
import {
  FiFileText,
  FiBriefcase,
  FiUser,
} from "react-icons/fi";
import { AiOutlineRead } from "react-icons/ai";
import { ChevronLeft, ChevronRight } from "lucide-react";

const jaro = Jaro({
  subsets: ["latin"],
  weight: ["400"],
});

const Nav = () => {
  const [isOpen, setIsOpen] = useState(false);

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
          href="/cv-feedback"
          icon={<FiFileText className="text-[#114b0a]" />}
          label={isOpen ? "CV Feedback" : ""}
        />
        <NavItem
          href="/available-job"
          icon={<FiBriefcase className="text-[#114b0a]" />}
          label={isOpen ? "Available Job" : ""}
        />
        <NavItem
          href="/interview-practice"
          icon={<FiUser className="text-[#114b0a]" />}
          label={isOpen ? "Interview Practice" : ""}
        />
        <NavItem
          href="/offline-resources"
          icon={<AiOutlineRead className="text-[#114b0a]" />}
          label={isOpen ? "Offline Resources" : ""}
        />
      </div>
    </div>
  );
};

export default Nav;
