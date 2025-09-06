"use client";

import { FcGoogle } from "react-icons/fc";

export default function GoogleLoginButton() {
  const handleGoogleLogin = () => {
    // window.location.href = "https://jobmate-api-3wuo.onrender.com/oauth/google/login";
  };

  return (
    <button
      type="button"
      onClick={handleGoogleLogin}
      className="flex items-center justify-center w-full gap-2 border border-gray-300 rounded-md py-2 hover:bg-gray-100 transition"
    >
      <FcGoogle size={20} />
      <span className="text-gray-700 font-medium">Continue with Google</span>
    </button>
  );
}
