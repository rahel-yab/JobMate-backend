"use client";
import { useRouter } from "next/navigation";
import React from "react";

interface ServiceProps {
  name: string;
  description: string;
  icon?: React.ReactNode;
  link?: string;
}

const ServiceComp = ({ name, description, icon, link }: ServiceProps) => {
  const router = useRouter();
  return (
    <div
      className="flex flex-col items-center w-56 p-4 rounded-lg shadow-sm 
                    hover:shadow-lg hover:scale-105 transition transform duration-300"
      onClick={() => router.push(link || "/")}
    >
      <div className="text-[#2CA58D] text-3xl">{icon || ""}</div>
      <h3 className="text-lg font-bold mt-2">{name}</h3>
      <p className="text-center text-sm text-gray-500 mt-1">{description}</p>
    </div>
  );
};

export default ServiceComp;
