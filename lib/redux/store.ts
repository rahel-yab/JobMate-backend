import { configureStore } from "@reduxjs/toolkit";
import { cvApi } from "./api/cvApi";
import { generalApi } from "./api/generalApi";

export const store = configureStore({
  reducer: {
    [cvApi.reducerPath]: cvApi.reducer,
    [generalApi.reducerPath]: generalApi.reducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware()
      .concat(cvApi.middleware)
      .concat(generalApi.middleware),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
