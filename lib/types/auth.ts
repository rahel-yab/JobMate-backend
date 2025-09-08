// lib/types/auth.ts
export interface User {
  id: string;
  name: string;
  email: string;
  acces_token?: string;
}
