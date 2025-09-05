import React from "react";
import { Button } from "./ui/Button";
import { Jaro } from "next/font/google";

const jaro = Jaro({
  subsets: ["latin"],
  weight: ["400"],
});

const NavBar = () => {
  return (
    <div className="fixed top-0 left-0 w-full z-50 bg-[#f6f6f6] flex justify-around items-center py-3">
      <h1 className={`${jaro.className} 2xl:text-3xl text-2xl`}>
        <span className="font-jaro text-[#217C6A]">Job</span>Mate
      </h1>
      <div className="flex">
        <a href="#home" className="px-4">
          Home
        </a>
        <a href="#service" className="px-4">
          Service
        </a>
      </div>
      <div className="flex gap-3 items-center">
        <p>Log In</p>
        <Button className="bg-[#2CA58D] text-white px-4">Sign Up</Button>
      </div>
    </div>
  );
};

export default NavBar;
