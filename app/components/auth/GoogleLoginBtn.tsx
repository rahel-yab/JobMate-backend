"use client";
import { FcGoogle } from "react-icons/fc";
// import { useRouter } from "next/navigation";
// import { useDispatch } from "react-redux";
// import { setCredentials } from "@/lib/redux/authSlice";
// import toast from "react-hot-toast";

export default function GoogleLoginButton() {
  // const router = useRouter();
  // const dispatch = useDispatch();

  const handleGoogleLogin = () => {
    window.location.href =
      "https://jobmate-api-0d1l.onrender.com/oauth/google/login";
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
