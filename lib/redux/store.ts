import { configureStore } from "@reduxjs/toolkit";
import { cvApi } from "./api/cvApi";

export const store = configureStore({
  reducer: {
    [cvApi.reducerPath]: cvApi.reducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware().concat(cvApi.middleware),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
