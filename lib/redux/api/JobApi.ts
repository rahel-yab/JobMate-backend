import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

export const jobApi = createApi({
  reducerPath: "jobApi",
  baseQuery: fetchBaseQuery({
    baseUrl: "https://jobmate-api-0d1l.onrender.com",
    prepareHeaders: (headers) => {
      const user = JSON.parse(localStorage.getItem("user") || "{}");

      const token = user?.acces_token;
      console.log(token);
      if (token) {
        headers.set("Authorization", `Bearer ${token}`);
      }
      return headers;
    },
  }),

  endpoints: (builder) => ({
    // 1. Get all job chats
    getAllChats: builder.query<any[], void>({
      query: () => ({
        url: "/jobs/chats",
        method: "GET",
      }),
    }),

    sendMsg: builder.mutation<
      { message: string; jobs: any[]; chat_id: string },
      { message: string; chat_id?: string }
    >({
      query: ({ message, chat_id }) => ({
        url: "/jobs/chat",
        method: "POST",
        body: { message, chat_id },
      }),
    }),

    // 3. Get single chat by ID
    getChatById: builder.query<any, string>({
      query: (id) => ({
        url: `/jobs/chat/${id}`,
        method: "GET",
      }),
    }),
  }),
});

export const { useGetAllChatsQuery, useSendMsgMutation, useGetChatByIdQuery } =
  jobApi;
