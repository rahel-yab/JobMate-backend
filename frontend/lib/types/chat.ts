/* import { ReactNode } from "react";

export type SkillGap = {
    skillName: string;
    currentLevel: number;
    recommendedLevel: number;
    importance?: string;
    improvementSuggestions?: string;
  };

export type BaseMessage = {
  id: number;
  sender: "ai" | "user";
  time?: string;
};

export type ChatMessage = BaseMessage & {
  type?: "chat";
  text: string | ReactNode;
};

export type CvAnalysisMessage = BaseMessage & {
    type: "cv-analysis";
    summary: string;
    strengths: string;
    weaknesses: string;
    improvements: string;
    skillGaps: SkillGap[];
  };

export type UploadMessage = BaseMessage & {
  type?: "upload";
  text: string;
  cvId?: string;
};


export type ApiMessage = {
    id: string;
    role: "user" | "assistant";
    content: string;
    timestamp: string; // ISO string
  };
  
  // API response for chat history
  export type ChatHistoryResponse = {
    chat_id: string;
    user_id: string;
    cv_id?: string; // optional
    messages: ApiMessage[];
    created_at: string;
    updated_at: string;
  };

export type ChatMessageType =
  | ChatMessage
  | CvAnalysisMessage
  | UploadMessage
  | ApiMessage
  | ChatHistoryResponse;

 */



  import { ReactNode } from "react";

  // --------------------- CV Data ---------------------
  export type SkillGap = {
    skillName: string;
    currentLevel: number;
    recommendedLevel: number;
    importance: string; // always required
    improvementSuggestions: string; // always required
  };
  
  
  export type BaseMessage = {
    id: number;
    sender: "ai" | "user";
    time?: string;
  };
  
  export type ChatMessage = {
    id: number;
    sender: "user" | "ai";
    type?: "chat";
    text: string | React.ReactNode;
    time: string;
  };
  
  export type CvAnalysisMessage = {
    id: number;
    sender: "ai";
    type: "cv-analysis";
    summary: string;
    strengths: string;
    weaknesses: string;
    improvements: string;
    skillGaps: SkillGap[];
    time: string;
  };
  
  export type UploadMessage = {
    id: number;
    sender: "ai";
    type?: "upload";
    text: string;
    cvId?: string;
    time?: string;
  };
  
  // --------------------- API Responses ---------------------
  export type UploadCVResponse = {
    success: boolean;
    message: string;
    details: {
      cvId: string;
      userId: string;
      fileName: string;
      createdAt: string;
    };
  };
  
  export type AnalyzeCVResponse = {
    success: boolean;
    message: string;
    details: {
      cvId: string;
      suggestions: {
        CVs: {
          extractedSkills: string[];
          extractedExperience: string[];
          extractedEducation: string[];
          summary: string;
        };
        CVFeedback: {
          strengths: string;
          weaknesses: string;
          improvementSuggestions: string;
        };
        SkillGaps: SkillGap[] | null;
      };
    };
  };



  export type MessageType = ChatMessage | CvAnalysisMessage | UploadMessage;


  // --------------------- Chat Types ---------------------
  export type ChatMessageType =
    | MessageType
    | ChatMessage
    | CvAnalysisMessage
    | UploadMessage;
  