"use client";

import { useState } from "react";
import { useRegisterMutation } from "@/lib/redux/api/authApi";
import { useLanguage } from "@/providers/language-provider";
import toast from "react-hot-toast";

export default function OTPForm({
  // fullName,
  email,
  password,
}: {
  fullName: string;
  email: string;
  password: string;
}) {
  const { t } = useLanguage();
  const [otp, setOtp] = useState("");
  const [error, setError] = useState("");

  const [registerUser, { isLoading }] = useRegisterMutation();

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    try {
      console.log({ email, password, otp });

      await registerUser({ email, password, otp }).unwrap();
      toast.success("Registered successfully! You can now login.");

      window.location.href = "/login";
    } catch {
      setError(t("otp_failed"));
    }
  };

  return (
    <div className="bg-gray-50 w-full min-h-screen flex items-center justify-center">
      <div className="w-full max-w-md p-8 rounded-xl bg-white shadow-lg">
        <h2 className="text-2xl font-bold text-teal-600 text-center mb-2">
          {t("otp_title")}
        </h2>
        <p className="text-gray-600 text-center mb-6 text-md">
          {t("otp_subtitle1")} <span className="font-bold">{email}</span>{" "}
          {t("otp_subtitle2")}
        </p>

        <form onSubmit={handleRegister} className="flex flex-col gap-5">
          {error && <p className="text-red-500 text-sm text-center">{error}</p>}

          <input
            id="otp"
            name="otp"
            type="text"
            placeholder={t("otp_placeholder")}
            value={otp}
            onChange={(e) => setOtp(e.target.value)}
            required
            className="p-3 border border-gray-300 rounded-md outline-none focus:ring-2 focus:ring-teal-500 focus:border-teal-500 text-center text-gray-700 text-lg"
          />

          <button
            type="submit"
            className="bg-teal-600 text-white py-3 rounded-md font-medium hover:bg-teal-700 transition"
            disabled={isLoading}
          >
            {isLoading ? t("otp_verifying") : t("otp_button")}
          </button>
        </form>
      </div>
    </div>
  );
}
