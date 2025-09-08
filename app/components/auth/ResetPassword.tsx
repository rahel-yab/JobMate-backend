"use client";

import { useState } from "react";
import { useResetPasswordMutation } from "@/lib/redux/api/authApi";
import toast from "react-hot-toast";
import { useSearchParams, useRouter } from "next/navigation";
import { useLanguage } from "@/providers/language-provider";

export default function ResetPassword() {
  const { t } = useLanguage();
  const [otp, setOtp] = useState("");
  const [new_password, setNewPassword] = useState("");
  const [resetPassword, { isLoading }] = useResetPasswordMutation();
  const searchParams = useSearchParams();
  const emailFromQuery = searchParams.get("email") || "";
  const [email, setEmail] = useState(emailFromQuery);
  const router = useRouter();
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await resetPassword({ email, otp, new_password }).unwrap();
      toast.success("✅ Password reset successfully!");
      setEmail("");
      setOtp("");
      setNewPassword("");
      router.push("/login");
    } catch (err) {
      toast.error(" Failed to reset password. Check your OTP or try again.");
      console.error(err);
    }
  };

  return (
    <div className="bg-gray-50 w-full min-h-screen flex items-center justify-center">
      <div className="w-full max-w-md p-8 rounded-xl bg-white shadow-lg">
        <h3 className="text-lg font-bold mb-4 text-teal-600 text-center">
          {t("reset_title")}
        </h3>
        <form onSubmit={handleSubmit} className="flex flex-col gap-3">
          <input
            type="email"
            placeholder={t("emailPlaceholder")}
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
            className="border border-gray-300 px-3 py-2 rounded"
          />
          <input
            type="text"
            placeholder="OTP"
            value={otp}
            onChange={(e) => setOtp(e.target.value)}
            required
            className="border border-gray-300 px-3 py-2 rounded"
          />
          <input
            type="password"
            placeholder={t("password")}
            value={new_password}
            onChange={(e) => setNewPassword(e.target.value)}
            required
            className="border border-gray-300 px-3 py-2 rounded"
          />
          <button
            type="submit"
            disabled={isLoading}
            className="px-4 py-2 rounded bg-teal-600 text-white hover:bg-teal-700"
          >
            {isLoading ? t("sending") : t("resetBtn")}
          </button>
        </form>
      </div>
    </div>
  );
}
