"use client";

import { useSelector } from "react-redux";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";
import { RootState } from "@/lib/redux/store";

interface ProtectedWrapperProps {
  children: React.ReactNode;
}

const unprotectedRoutes = ["/login", "/register", "/reset-password", "/"];

export default function ProtectedWrapper({ children }: ProtectedWrapperProps) {
  const reduxToken = useSelector((state: RootState) => state.auth.accessToken);
  const router = useRouter();
  const pathname = usePathname(); // ✅ declare before use

  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem("accessToken") || reduxToken;
    const cleanPath = pathname.split("?")[0]; // ✅ now safe

    if (!token && !unprotectedRoutes.includes(cleanPath)) {
      router.replace(`/login?redirect=${cleanPath}`);
      return;
    }

    if (token && ["/login", "/register", "/"].includes(cleanPath)) {
      router.replace("/dashboard");
      return;
    }

    setIsReady(true);
  }, [reduxToken, pathname, router]);

  if (!isReady)
    return (
      <div className="flex items-center justify-center min-h-screen">
        <h1 className="text-center text-gray-600 text-2xl">Loading...</h1>
      </div>
    );

  return <>{children}</>;
}
