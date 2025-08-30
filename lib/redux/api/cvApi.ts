import { createApi, fetchBaseQuery } from "@reduxjs/toolkit/query/react";

/* export const cvApi = createApi({
  reducerPath: "cvApi",
  baseQuery: fetchBaseQuery({ baseUrl: "http://localhost:8080" }),
  endpoints: (builder) => ({
    uploadCV: builder.mutation({
      query: ({ userId, rawText, file }: any) => {
        const formData = new FormData();
        formData.append("userId", userId);
        if (rawText) formData.append("rawText", rawText);
        if (file) formData.append("file", file);
        return {
          url: "/cv",
          method: "POST",
          body: formData,
        };
      },
    }),
    analyzeCV: builder.mutation({
      query: (cvId: string) => ({
        url: `/cv/${cvId}/analyze`,
        method: "POST",
      }),
    }),
  }),
});
 */


export const cvApi = createApi({
    reducerPath: "cvApi",
    baseQuery: async ({ endpoint, body }) => {
      // Mock delay
      await new Promise((res) => setTimeout(res, 1000));
  
      if (endpoint === "uploadCV") {
        return {
          data: {
            success: true,
            message: "CV uploaded successfully",
            details: {
              cvId: "abc123",
              userId: body.userId,
              fileName: "resume.pdf",
              createdAt: new Date().toISOString(),
            },
          },
        };
      }
  
      if (endpoint === "analyzeCV") {
        return {
          data: {
            success: true,
            message: "CV analyzed successfully",
            details: {
              cvId: "abc123",
              suggestions: {
                CVs: {
                  extractedSkills: ["Go", "Docker", "Kubernetes"],
                  extractedExperience: [
                    "Software Engineer at XYZ",
                    "DevOps Engineer at ABC",
                  ],
                  extractedEducation: ["BSc Computer Science"],
                  summary: "Experienced software engineer with DevOps expertise.",
                },
                CVFeedback: {
                  strengths: "Strong backend and DevOps skills",
                  weaknesses: "Limited frontend experience",
                  improvementSuggestions:
                    "Gain more experience in React and frontend frameworks",
                },
                SkillGaps: [
                  {
                    skillName: "React",
                    currentLevel: 1,
                    recommendedLevel: 4,
                    importance: "important",
                    improvementSuggestions:
                      "Take React course and build small projects",
                  },
                ],
              },
            },
          },
        };
      }
  
      return { error: { message: "Unknown endpoint" } };
    },
    endpoints: (builder) => ({
      uploadCV: builder.mutation({
        query: (body) => ({ endpoint: "uploadCV", body }),
      }),
      analyzeCV: builder.mutation({
        query: (cvId) => ({ endpoint: "analyzeCV", body: { cvId } }),
      }),
    }),
  });
  



export const { useUploadCVMutation, useAnalyzeCVMutation } = cvApi;
