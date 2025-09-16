"use client";

import { useLogoutMutation } from "@/lib/redux/api/authApi";
import { clearAuth } from "@/lib/redux/authSlice";
import { useDispatch } from "react-redux";
import { useRouter } from "next/navigation";

export function useLogout() {
  const [logoutApi] = useLogoutMutation();
  const dispatch = useDispatch();
  const router = useRouter();

  const handleLogout = async () => {
    try {
      await logoutApi().unwrap(); // calls /auth/logout
    } catch {
      // error ignored
    } finally {
      dispatch(clearAuth()); // clear Redux state
      router.push("/login"); 
    }
  };

  return handleLogout;
}
