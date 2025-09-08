import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";
import { RootState } from "@/lib/redux/store";
import { JobCardProps } from "@/app/components/jobSearch/Jobcard";

export const jobApi = createApi({
  reducerPath: "jobApi",
  baseQuery: fetchBaseQuery({
    baseUrl: "https://g6-jobmate-3.onrender.com",
    prepareHeaders: (headers, { getState }) => {
      const state = getState() as RootState;
      const token = state.auth.user?.acces_token;
      console.log("toooooooooooken", token);
      if (token) {
        headers.set("Authorization", `Bearer ${token}`);
      }
      return headers;
    },
  }),

  endpoints: (builder) => ({
    // 1. Get all job chats
    getAllChats: builder.query({
      query: () => ({
        url: "/jobs/chats",
        method: "GET",
      }),
    }),

    sendMsg: builder.mutation<
      { message: string; jobs: JobCardProps[]; chat_id: string },
      { message: string; chat_id?: string }
    >({
      query: ({ message, chat_id }) => ({
        url: "/jobs/chat",
        method: "POST",
        body: { message, chat_id },
      }),
    }),

    // 3. Get single chat by ID
    getChatById: builder.query({
      query: (id) => ({
        url: `/jobs/chat/${id}`,
        method: "GET",
      }),
    }),
  }),
});

export const { useGetAllChatsQuery, useSendMsgMutation, useGetChatByIdQuery } =
  jobApi;
