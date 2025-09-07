import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";
import type { RootState } from "../store";
import { clearAuth, setCredentials } from "../authSlice";

// Base query
const baseQuery = fetchBaseQuery({
  baseUrl: "https://g6-jobmate-3.onrender.com",
  prepareHeaders: (headers, { getState }) => {
    //const token = (getState() as RootState).auth.accessToken;

    const state = getState() as RootState;
    console.log("Auth state in prepareHeaders:", state.auth);
    //const token = (getState() as RootState).auth.accessToken;
    const token = state.auth.user?.acces_token; // ✅ correct path
    console.log("Token in prepareHeaders:", token);


    if (token) headers.set("authorization", `Bearer ${token}`);
    return headers;
  },
});   
// handle 401 + automatic refresh
const baseQueryWithReauth = async (args: any, api: any, extraOptions: any) => {
  let result = await baseQuery(args, api, extraOptions);

  if (result.error && result.error.status === 401) {
    // refresh token
    const refreshResult: any = await baseQuery(
      { url: "/auth/refresh", method: "POST", credentials: "include" },
      api,
      extraOptions
    );

    if (refreshResult.data) {
      // Update store with new token
      api.dispatch(
        setCredentials({
          user: refreshResult.data.user || api.getState().auth.user,
          accessToken: refreshResult.data.access_token,
        })
      );
      // Retry original request with new token
      result = await baseQuery(args, api, extraOptions);
    } else {
      // Refresh failed → log out
      api.dispatch(clearAuth());
    }
  }

  return result;
};

export const authApi = createApi({
  reducerPath: "authApi",
  baseQuery: baseQueryWithReauth,
  endpoints: (builder) => ({
    login: builder.mutation<any, { email: string; password: string }>({
      query: (body) => ({ url: "/auth/login", method: "POST", body }),
    }),
    register: builder.mutation<any, { email: string; password: string; otp: string }>({
      query: (body) => ({ url: "/auth/register", method: "POST", body }),
    }),
    requestOtp: builder.mutation<any, { email: string }>({
      query: (body) => ({ url: "/auth/request-otp", method: "POST", body }),
    }),
    logout: builder.mutation<void, void>({
      query: () => ({ url: "/auth/logout", method: "POST" }),
    }),
    
    requestPasswordReset: builder.mutation<any, { email: string }>({
      query: (body) => ({
        url: "/auth/request-password-reset-otp",
        method: "POST",
        body,
      }),
    }),
    resetPassword: builder.mutation<any, { email: string; otp: string; new_password: string }>({
  query: ({ email, otp, new_password }) => ({
    url: "/auth/reset-password",
    method: "POST",
    body: { email, otp, new_password },
  }),
}),


      }),
    });

export const {
  useLoginMutation,
  useRegisterMutation,
  useRequestOtpMutation,
  useLogoutMutation,
  useRequestPasswordResetMutation,
  useResetPasswordMutation,
} = authApi;
