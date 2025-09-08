"use client";

import { useState } from "react";
import OTPForm from "./OTPForm";
import { User, Mail, Lock } from "lucide-react";
import Link from "next/link";
import { useRequestOtpMutation } from "@/lib/redux/api/authApi";
import { useLanguage } from "@/providers/language-provider";
// import toast from "react-hot-toast";

export default function RegisterForm() {
  const validatePassword = (pwd: string) => {
    const errors: string[] = [];
    if (pwd.length < 8) errors.push("8 characters");
    if (!/[A-Z]/.test(pwd)) errors.push("1 uppercase letter");
    if (!/[a-z]/.test(pwd)) errors.push("1 lowercase letter");
    if (!/[0-9]/.test(pwd)) errors.push("1 number");
    if (!/[!@#$%^&*]/.test(pwd)) errors.push("1 special character");
    return errors;
  };

  const [passwordErrors, setPasswordErrors] = useState<string[]>([]);

  const { t } = useLanguage();
  const [step, setStep] = useState<"details" | "otp">("details");
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const [requestOtp, { isLoading }] = useRequestOtpMutation();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    try {
      // const res =
      await requestOtp({ email }).unwrap();
      setStep("otp");
    } catch {
      setError("Failed to send OTP. Try again.");
    }
  };

  if (step === "otp") {
    return <OTPForm fullName={fullName} email={email} password={password} />;
  }

  return (
    <div className="w-full max-w-lg p-8 rounded-xl bg-white shadow-lg font-serif">
      <h2 className="text-2xl font-bold text-teal-600 text-center">
        {t("r_join")}
      </h2>
      <p className="text-gray-500 mb-6 text-center">{t("r_create")}</p>

      <form onSubmit={handleSubmit} className="flex flex-col gap-5">
        {error && <p className="text-red-500 text-sm">{error}</p>}

        <div className="flex items-center gap-2 border rounded px-3 border-gray-300">
          <User className="text-gray-500 w-5 h-5" />
          <input
            type="text"
            id="fullName"
            name="fullName"
            placeholder={t("r_fullName")}
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
            required
            className="flex-1 p-3 outline-none text-gray-700"
          />
        </div>

        <div className="flex items-center gap-2 border rounded px-3 border-gray-300">
          <Mail className="text-gray-500 w-5 h-5" />
          <input
            type="email"
            id="email"
            name="email"
            placeholder={t("email")}
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            className="flex-1 p-3 outline-none text-gray-700"
          />
        </div>

        <div className="flex flex-col gap-1 w-full">
          <div className="flex items-center gap-2 border rounded px-3 border-gray-300">
            <Lock className="text-gray-500 w-5 h-5" />
            <input
              type="password"
              id="password"
              name="password"
              placeholder={t("password")}
              value={password}
              onChange={(e) => {
                setPassword(e.target.value);
                setPasswordErrors(validatePassword(e.target.value));
              }}
              required
              className="flex-1 p-3 outline-none text-gray-700"
            />
          </div>

          {/* Single-line password error message */}
          {password && passwordErrors.length > 0 && (
            <p className="text-xs text-red-500 mt-1">
              {" "}
              Atleast {passwordErrors.join(", ")}
            </p>
          )}
        </div>

        <button
          type="submit"
          className="bg-teal-600 text-white py-3 rounded-md font-medium hover:bg-teal-700 transition"
          disabled={isLoading}
        >
          {isLoading ? "Signing up..." : t("r_createAccount")}
        </button>
      </form>

      <div className="mt-4 text-center flex justify-center">
        <p className="text-sm text-gray-500">
          {t("r_noAccount")}{" "}
          <Link
            className="text-teal-600 cursor-pointer hover:underline"
            href="/login"
          >
            {t("r_login")}
          </Link>
        </p>
      </div>
    </div>
  );
}
