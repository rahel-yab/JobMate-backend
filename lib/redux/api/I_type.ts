export type SessionType =
  | "technical"
  | "Technical"
  | "general"
  | "General"
  | "behavioral"
  | "Behavioral";

export interface FreeformChat {
  chat_id: string;
  session_type: SessionType;
  last_message: string;
  created_at: string;
  updated_at: string;
}

export interface GetFreeformUserChatsResponse {
  data: {
    chats: FreeformChat[];
    total: number;
  };
  message: string;
  success: boolean;
}
interface UserChat {
  chat_id: string;
  field: string;
  user_profile: Record<string, unknown>;
  current_question: number;
  total_questions: number;
  is_completed: boolean;
  last_message: string;
  created_at: string;
  updated_at: string;
}

export interface GetStructuredUserChatsResponse {
  data: {
    chats: UserChat[];
    total: number;
  };
  message: string;
  success: boolean;
}
