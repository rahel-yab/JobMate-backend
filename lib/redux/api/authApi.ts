import {
  createApi,
  fetchBaseQuery,
  FetchArgs,
  FetchBaseQueryError,
  BaseQueryApi,
} from "@reduxjs/toolkit/query/react";
import type { RootState } from "../store";
import { clearAuth, setCredentials } from "../authSlice";
import { User } from "@/lib/types/auth";

// Base query with headers
const baseQuery = fetchBaseQuery({
  baseUrl: "https://g6-jobmate-3.onrender.com",
  prepareHeaders: (headers, api) => {
    const state = api.getState() as RootState;
    const token = state.auth.user?.acces_token;
    if (token) headers.set("authorization", `Bearer ${token}`);
    return headers;
  },
});

// Handle 401 + auto refresh
const baseQueryWithReauth = async (
  args: string | FetchArgs,
  api: BaseQueryApi,
  extraOptions: object
) => {
  let result = await baseQuery(args, api, extraOptions);

  if ((result as { error?: FetchBaseQueryError }).error?.status === 401) {
    const refreshResult = await baseQuery(
      { url: "/auth/refresh", method: "POST", credentials: "include" },
      api,
      extraOptions
    );

    if ("data" in refreshResult) {
      api.dispatch(
        setCredentials({
          user: (refreshResult.data as { user: User }).user || (api.getState() as RootState).auth.user!,
          accessToken: (refreshResult.data as { access_token: string }).access_token,
        })
      );
      result = await baseQuery(args, api, extraOptions);
    } else {
      api.dispatch(clearAuth());
    }
  }

  return result;
};

// API endpoints
export const authApi = createApi({
  reducerPath: "authApi",
  baseQuery: baseQueryWithReauth,
  endpoints: (builder) => ({
    login: builder.mutation<{ access_token: string; user: User }, { email: string; password: string }>({
      query: (body) => ({ url: "/auth/login", method: "POST", body }),
    }),
    register: builder.mutation<{ user: User; access_token: string }, { firstName:string;  lastName:string; email: string; password: string; otp: string }>({
      query: (body) => ({ url: "/auth/register", method: "POST", body }),
    }),
    requestOtp: builder.mutation<{ success: boolean }, { email: string }>({
      query: (body) => ({ url: "/auth/request-otp", method: "POST", body }),
    }),
    logout: builder.mutation<void, void>({
      query: () => ({ url: "/auth/logout", method: "POST" }),
    }),
    requestPasswordReset: builder.mutation<{ success: boolean }, { email: string }>({
      query: (body) => ({
        url: "/auth/request-password-reset-otp",
        method: "POST",
        body,
      }),
    }),
    resetPassword: builder.mutation<{ success: boolean }, { email: string; otp: string; new_password: string }>({
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
