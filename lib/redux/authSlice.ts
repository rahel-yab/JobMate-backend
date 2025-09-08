import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import type { User } from "../types/auth";

interface AuthState {
  user: User | null;
  accessToken: string | null | undefined;
}

const initialState: AuthState = {
  user:
    typeof window !== "undefined" && localStorage.getItem("user")
      ? JSON.parse(localStorage.getItem("user")!)
      : null,
  accessToken:
    typeof window !== "undefined" && localStorage.getItem("accessToken")
      ? localStorage.getItem("accessToken")
      : null,
};

const authSlice = createSlice({
  name: "auth",
  initialState,
  reducers: {
    setCredentials: (
  state,
  action: PayloadAction<{ user: User; accessToken?: string }>
) => {
  state.user = action.payload.user;
  state.accessToken = action.payload.user.acces_token;

  if (action.payload.user.acces_token) {
    localStorage.setItem("accessToken", action.payload.user.acces_token);
  }
  localStorage.setItem("user", JSON.stringify(action.payload.user));
},

    clearAuth: (state) => {
      state.user = null;
      state.accessToken = null;
      localStorage.removeItem("accessToken");
      localStorage.removeItem("user");
    },
  },
});

export const { setCredentials, clearAuth } = authSlice.actions;
export default authSlice.reducer;
