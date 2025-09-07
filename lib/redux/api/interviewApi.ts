import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";
import type { RootState } from "../store";
import type {
  GetFreeformUserChatsResponse,
  GetStructuredUserChatsResponse,
} from "./I_type";

export const interviewApi = createApi({
  reducerPath: "interviewApi",
  baseQuery: fetchBaseQuery({
    baseUrl: "https://jobmate-api-0d1l.onrender.com",
    prepareHeaders: (headers, { getState }) => {
      // 🔑 attach JWT from state if available
      // const state = getState() as RootState;
      // console.log("Auth state in prepareHeaders:", state.auth);
      // const token = (getState() as any).auth?.accessToken;
      // console.log("Token in prepareHeaders:", token);
      const state = getState() as RootState;
      // console.log("Auth state in prepareHeaders:", state.auth);
      // //const token = (getState() as RootState).auth.accessToken;
      const token = state.auth.user?.acces_token; // ✅ correct path

      if (token) {
        headers.set("Authorization", `Bearer ${token}`);
      }
      return headers;
    },
  }),
  endpoints: (builder) => ({
    // ===== FREEFORM =====
    createFreeformSession: builder.mutation({
      query: (body) => ({
        url: "/interview/freeform/session",
        method: "POST",
        body,
      }),
    }),
    sendFreeformMessage: builder.mutation({
      query: ({ chat_id, message }) => ({
        url: `/interview/freeform/${chat_id}/message`, // 👈 dynamic path
        method: "POST",
        body: { message }, // ✅ only message is sent in body
      }),
    }),

    getFreeformHistory: builder.query({
      query: (chat_id) => `/interview/freeform/${chat_id}/history`,
    }),
    getFreeformUserChats: builder.query<GetFreeformUserChatsResponse, void>({
      query: () => "/interview/freeform/user/chats",
    }),

    // ===== STRUCTURED =====
    startStructuredInterview: builder.mutation({
      query: (body) => ({
        url: "/interview/structured/start",
        method: "POST",
        body,
      }),
    }),
    answerStructuredQuestion: builder.mutation({
      query: ({ chat_id, answer }) => ({
        url: `/interview/structured/${chat_id}/answer`,
        method: "POST",
        body: { answer },
      }),
    }),
    getStructuredHistory: builder.query({
      query: (chat_id) => `/interview/structured/${chat_id}/history`,
    }),
    // resumeStructuredInterview: builder.query({
    //   query: ({ chat_id, preferred_language }) =>
    //     `/interview/structured/continue/${chat_id}`,
    // }),
    resumeStructuredInterview: builder.query({
      query: ({ chat_id }) => ({
        url: `/interview/structured/continue/${chat_id}`,
        method: "GET",
        // If preferred_language is a query param, add it here:
      }),
      transformResponse: (response) => response.data, // unwrap the data directly
    }),

    getStructuredUserChats: builder.query<GetStructuredUserChatsResponse, void>(
      {
        query: () => "/interview/structured/user/chats",
      }
    ),
  }),
});

export const {
  // freeform
  useCreateFreeformSessionMutation,
  useSendFreeformMessageMutation,
  useGetFreeformHistoryQuery,
  useGetFreeformUserChatsQuery,
  // structured
  useStartStructuredInterviewMutation,
  useAnswerStructuredQuestionMutation,
  useGetStructuredHistoryQuery,
  useResumeStructuredInterviewQuery,
  useLazyResumeStructuredInterviewQuery,
  useGetStructuredUserChatsQuery,
} = interviewApi;
