 import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

export const cvApi = createApi({
  reducerPath: "cvApi",
  baseQuery: fetchBaseQuery({
    baseUrl:  "https://jobmate-api-0d1l.onrender.com", 
    prepareHeaders: (headers, { getState }) => {
      
      const token ="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTcxNzk1MDUsImlhdCI6MTc1NzE3ODYwNSwibGFuZyI6ImVuIiwic3ViIjoiNjhiOWEwNmFmZjM2ZmZmM2E4MjBmZDIyIn0.6fkSTkt0rK75v5MrKVtftSJMLfxAWodhbhLDZVI4dYg"
      if (token) {
        headers.set("Authorization", `Bearer ${token}`);
      }
      return headers;
    },
  }),

  endpoints: (builder) => ({
    uploadCV: builder.mutation({
      query: ({ rawText, file }: { rawText?: string; file?: File }) => {
        const formData = new FormData();

        if (rawText && file) {
          throw new Error("Only one of rawText or file can be provided");
        }

        if (rawText) {
          formData.append("rawText", rawText);
        } else if (file) {
          formData.append("file", file);
        } else {
          throw new Error("Either rawText or file must be provided");
        }

        return {
          url: "/cv",
          method: "POST",
          body: formData,
        };
      },
    }),

    analyzeCV: builder.mutation({
      query: (cvId: string) => ({
        url: `/cv/${cvId}/analyze`,
        method: "POST",
      }),
    }),

    startSession: builder.mutation<{ chat_id: string }, { cv_id?: string }>({
      query: (body) => ({
        url: "/cv/chat/session",
        method: "POST",
        body,
      }),
    }),

    sendMessage: builder.mutation<
      { content: string; chat_id: string; timestamp: string },
      { chat_id: string; message: string; cv_id?: string }
    >({
      query: ({ chat_id, ...body }) => ({
        url: `/cv/chat/${chat_id}/message`,
        method: "POST",
        body,
      }),
    }),

    getUserChats: builder.query<any[], void>({
      query: () => ({
        url: "/cv/chat/user",
        method: "GET",
      }),
    }),

    getChatHistory: builder.query<any, { chat_id: string }>({
      query: ({ chat_id }) => ({
        url: `/cv/chat/${chat_id}/history`,
        method: "GET",
      }),
    }),
  }),
});

export const {
  useUploadCVMutation,
  useAnalyzeCVMutation,
  useStartSessionMutation,
  useSendMessageMutation,
  useGetUserChatsQuery,
  useGetChatHistoryQuery,
} = cvApi;
