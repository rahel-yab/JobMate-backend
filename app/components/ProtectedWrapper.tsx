"use client";

import { useSelector } from "react-redux";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState } from "react";

interface ProtectedWrapperProps {
  children: React.ReactNode;
}

const unprotectedRoutes = ["/login", "/register", "/reset-password",  "/"];

export default function ProtectedWrapper({ children }: ProtectedWrapperProps) {
  const reduxToken = useSelector((state: any) => state.auth.accessToken);
  const router = useRouter();
  const pathname = usePathname();

  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    const token = localStorage.getItem("accessToken") || reduxToken;

    if (!token && !unprotectedRoutes.includes(pathname)) {
      router.replace(`/login?redirect=${pathname}`);
      return;
    }

    if (token && unprotectedRoutes.includes(pathname)) {
      router.replace("/");
      return;
    }

    setIsReady(true);
  }, [reduxToken, pathname, router]);

  // Prevent server/client mismatch by not rendering anything until check is done
  if (!isReady) return (
      <div className="flex items-center justify-center min-h-screen">
        <h1 className="text-center text-gray-600 text-2xl">Loading...</h1>
      </div>
    );

  return <>{children}</>;
}
