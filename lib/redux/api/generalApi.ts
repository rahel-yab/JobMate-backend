/* import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

export const generalApi = createApi({
  reducerPath: "generalApi",
  baseQuery: fetchBaseQuery({
    baseUrl: "https://your-api-domain.com", 
    prepareHeaders: (headers) => {
      const token = "YOUR_ACCESS_TOKEN"; 
      if (token) {
        headers.set("Authorization", `Bearer ${token}`);
      }
      return headers;
    },
  }),
  endpoints: (builder) => ({
    sendMessage: builder.mutation<
      any, // response type
      { user_id: string; message: string; is_from_user: boolean } // request body type
    >({
      query: (body) => ({
        url: "/chat",
        method: "POST",
        body,
      }),
    }),
  }),
});

export const { useSendMessageMutation } = generalApi;
 */


import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

export const generalApi = createApi({
  reducerPath: "generalApi",

  baseQuery: async ({ url, method, body }) => {
    if (url === "/chat" && method === "POST") {
      const { message, is_from_user } = body as {
        user_id: string;
        message: string;
        is_from_user: boolean;
      };

      
      await new Promise((res) => setTimeout(res, 600));

      return {
        data: {
          success: true,
          reply: is_from_user
            ? `Got your message: "${message}". Here's a mock AI response.`
            : "CV Message sent successfully.",
        },
      };
    }

   
    return { error: { status: 404, data: "Not mocked" } };
  },
  endpoints: (builder) => ({
    sendMessage: builder.mutation<
      { success: boolean; reply: string },
      { user_id: string; message: string; is_from_user: boolean } 
    >({
      query: (body) => ({
        url: "/chat",
        method: "POST",
        body,
      }),
    }),
  }),
});

export const { useSendMessageMutation } = generalApi;
