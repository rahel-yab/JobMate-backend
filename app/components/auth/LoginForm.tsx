"use client";

import { useState } from "react";
import { Mail, Lock } from "lucide-react";
import Link from "next/link";
import { useLoginMutation } from "@/lib/redux/api/authApi";
import { setCredentials } from "@/lib/redux/authSlice";
import { useDispatch } from "react-redux";

import GoogleLoginButton from "./GoogleLoginBtn";
import { useRouter, useSearchParams } from "next/navigation";
import { useLanguage } from "@/providers/language-provider";

export default function LoginForm() {
  const { t } = useLanguage();
  const router = useRouter();
  const searchParams = useSearchParams();

  const redirect = searchParams.get("redirect") || "/";

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const dispatch = useDispatch();
  const [login, { isLoading }] = useLoginMutation();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    try {
      const data = await login({ email, password }).unwrap();
      dispatch(
        setCredentials({
          user: data.user,
          accessToken: data.user.access_token,
        })
      );
      router.push(redirect);
    } catch {
      setError("Login failed. Please check your credentials.");
    }
  };

  const handleGoogleLogin = () => {
    // window.location.href = "http://localhost:8080/oauth/google/login";
  };

  return (
    <div className="w-full max-w-lg p-8 rounded-xl bg-white shadow-lg font-serif">
      <h2 className="text-2xl font-bold text-teal-600 text-center">{t("l_welcome")}</h2>
      <p className="text-gray-500 mb-6 text-center">{t("l_subtitle")}</p>

      <form onSubmit={handleSubmit} className="flex flex-col gap-5">
        {error && <p className="text-red-500 text-sm">{error}</p>}

        <div className="flex items-center gap-2 border rounded px-3 border-gray-300">
          <Mail className="text-gray-500 w-5 h-5" />
          <input
            type="email"
            id="loginEmail"
            name="email"
            placeholder={t("email")}
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            className="flex-1 p-3 outline-none text-gray-800"
          />
        </div>

        <div className="flex items-center gap-2 border rounded px-3 border-gray-300">
          <Lock className="text-gray-500 w-5 h-5" />
          <input
            type="password"
            id="loginPassword"
            name="password"
            placeholder={t("password")}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            className="flex-1 p-3 outline-none text-gray-800"
          />
        </div>

        <button
          type="submit"
          className="bg-teal-600 text-white py-3 rounded-md font-medium hover:bg-teal-700 transition mt-2"
          disabled={isLoading}
        >
          {isLoading ? t("l_signingIn") : t("l_signIn")}
        </button>
      </form>

      <div className="flex items-center gap-2 my-2">
        <hr className="flex-1 border-gray-200" />
        <span className="text-gray-500 text-sm">OR</span>
        <hr className="flex-1 border-gray-200" />
      </div>

      <GoogleLoginButton />

      <div className="mt-4 text-center flex justify-center">
        <p className="text-sm text-gray-500">
          {t("l_noAccount")}{" "}
          <Link className="text-teal-600 cursor-pointer hover:underline" href="/register">
            {t("l_register")}
          </Link>
        </p>
      </div>
    </div>
  );
}
