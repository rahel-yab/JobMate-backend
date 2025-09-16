import { ReactNode } from "react";

export type SkillGap = {
  skill: string;
  gap: string;
};

export type ChatMessageType = {
  id: number;
  sender: "ai" | "user";
  text: string | ReactNode;
  time: string;
  type?: "cv-analysis";
  summary?: string;
  strengths?: string;
  weaknesses?: string;
  improvements?: string;
  skillGaps?: SkillGap[];
};
