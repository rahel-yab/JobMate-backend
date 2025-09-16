"use client";
import React from "react";
import { useRouter } from "next/navigation";
import { Button } from "../components/ui/Button";

const ErrorPage = () => {
  const router = useRouter();
  return (
    <div className="flex flex-col items-center justify-center min-h-120 text-center ">
      <div className="">
        <h1 className="text-8xl font-bold mt-10 text-[#2CA58D]">404</h1>
        <h2 className="text-2xl font-semibold"> Page Not Found</h2>
        <p className="text-sm text-gray-500 mt-4 mb-4">
          Something went wrong. Try again Later
        </p>
        <Button
          className="bg-[#2CA58D] text-white px-4"
          onClick={() => router.push("/")}
        >
          Go Home
        </Button>
      </div>
    </div>
  );
};

export default ErrorPage;
