"use client";

import { useState } from "react";
import { useRequestPasswordResetMutation } from "@/lib/redux/api/authApi";
import toast from "react-hot-toast";
import { useRouter } from "next/navigation";
import { useLanguage } from "@/providers/language-provider";


export default function ForgotPassword({ onClose }: { onClose: () => void }) {
const { t } = useLanguage();
  const [email, setEmail] = useState("");
  const [requestReset, { isLoading }] = useRequestPasswordResetMutation();
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await requestReset({ email }).unwrap();
      toast.success("✅ Password reset OTP sent to your email!");
      
      router.push(`/reset-password?email=${encodeURIComponent(email)}`);
    } catch (err) {
      toast.error("❌ Failed to send reset OTP. Try again.");
      console.log("❌ Failed to send reset OTP. Try again.",err);
    }
  };

  return (
    <>
      <h3 className="text-lg font-bold mb-4 text-teal-600">{t("f_title")}</h3>
      <form onSubmit={handleSubmit} className="flex flex-col gap-3">
        <input
          type="email"
            id="email"
            name="email"
          placeholder={t("emailPlaceholder")}
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
          className="border border-gray-300 px-3 py-2 rounded outline-none"
        />
        <div className="flex justify-end gap-2">
          <button
            type="button"
            onClick={onClose}
            className="px-4 py-2 rounded bg-gray-200 hover:bg-gray-300"
          >
            {t("cancel")}
          </button>
          <button
            type="submit"
            disabled={isLoading}
            className="px-4 py-2 rounded bg-teal-600 text-white hover:bg-teal-700"
          >
            {isLoading ? t("sending") : t("sendOtp")}
          </button>
        </div>
      </form>
    </>
  );
}
