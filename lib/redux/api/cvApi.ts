/* import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";
import { RootState } from "@/lib/redux/store";


 export const cvApi = createApi({
  reducerPath: "cvApi",
  baseQuery: fetchBaseQuery({
    baseUrl: "https://jobmate-api-0d1l.onrender.com",
    prepareHeaders: (headers, { getState }) => {
      const state = getState() as RootState;
      console.log("Auth state in prepareHeaders:", state.auth);
      //const token = (getState() as RootState).auth.accessToken;
      const token = state.auth.user?.acces_token; // ✅ correct path
      console.log("Token in prepareHeaders:", token);


     //const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTcyMjE0NzMsImlhdCI6MTc1NzIyMDU3MywibGFuZyI6ImVuIiwic3ViIjoiNjhiOWEwNmFmZjM2ZmZmM2E4MjBmZDIyIn0.37JA3tG6_hkrKuV1v4Z4vBU3tqnHJbKPprLbeDeCcnU"
      if (token) {
        headers.set("Authorization", `Bearer ${token}`);
      }
      return headers;
    },
  }),

  endpoints: (builder) => ({
   uploadCV: builder.mutation({
  query: ({ rawText, file }: { rawText?: string; file?: File }) => {
    if (rawText && file) {
      throw new Error("Only one of rawText or file can be provided");
    }

    if (file) {
      // File upload requires multipart/form-data
      const formData = new FormData();
      formData.append("file", file);

      return {
        url: "/cv",
        method: "POST",
        body: formData,
      };
    } else if (rawText) {
      // Raw text can be JSON
      return {
        url: "/cv",
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ rawText }),
      };
    } else {
      throw new Error("Either rawText or file must be provided");
    }
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
 */




import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";
import { RootState } from "@/lib/redux/store";


 export const cvApi = createApi({
  reducerPath: "cvApi",
  baseQuery: fetchBaseQuery({
    baseUrl: "https://g6-jobmate-3.onrender.com",
    prepareHeaders: (headers, { getState }) => {
      const state = getState() as RootState;
      console.log("Auth state in prepareHeaders:", state.auth);
      //const token = (getState() as RootState).auth.accessToken;
      const token = state.auth.user?.acces_token; // ✅ correct path
      console.log("Token in prepareHeaders:", token);


     //const token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3NTcyMjE0NzMsImlhdCI6MTc1NzIyMDU3MywibGFuZyI6ImVuIiwic3ViIjoiNjhiOWEwNmFmZjM2ZmZmM2E4MjBmZDIyIn0.37JA3tG6_hkrKuV1v4Z4vBU3tqnHJbKPprLbeDeCcnU"
      if (token) {
        headers.set("Authorization", `Bearer ${token}`);
      }
      return headers;
    },
  }),

  endpoints: (builder) => ({
   uploadCV: builder.mutation({
  query: ({ rawText, file }: { rawText?: string; file?: File }) => {
    if (rawText && file) {
      throw new Error("Only one of rawText or file can be provided");
    }

    if (file) {
      // File upload requires multipart/form-data
      const formData = new FormData();
      formData.append("file", file);

      return {
        url: "/cv",
        method: "POST",
        body: formData,
      };
    } else if (rawText) {
      // Raw text can be JSON
      return {
        url: "/cv",
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ rawText }),
      };
    } else {
      throw new Error("Either rawText or file must be provided");
    }
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