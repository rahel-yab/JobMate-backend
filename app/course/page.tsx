// "use client";

// import * as React from "react";
// import { Badge } from "@/app/components/ui/Badge";
// import { ExternalLink } from "lucide-react";

// interface Course {
//   Title: string;
//   Provider: string;
//   URL: string;
//   Description: string;
//   Skill: string;
// }

// interface CourseCardProps {
//   course: Course;
// }

// const CourseCard: React.FC<CourseCardProps> = ({ course }) => {
//   return (
//     <div className="bg-[#F3F5F9] rounded-lg shadow-md p-6 transition-shadow hover:shadow-lg">
//       <div className="flex items-start justify-between mb-3">
//         {/* Online Course Badge */}
//         <Badge
//           variant="outline"
//           className="mb-2 bg-white text-black border-gray-300 shadow-sm"
//         >
//           Online Course
//         </Badge>

//         {/* View Resource Button */}
//         <a
//           href={course.URL}
//           target="_blank"
//           rel="noopener noreferrer"
//           className="inline-flex items-center gap-1 rounded-full bg-white text-gray-800 px-3 py-1 text-sm font-medium shadow-md hover:shadow-lg hover:bg-gray-100 transition"
//         >
//           <ExternalLink className="h-3 w-3" />
//           View Resource
//         </a>
//       </div>

//       <h3 className="text-lg font-semibold text-gray-900 mb-2 leading-snug">
//         {course.Title}
//       </h3>

//       <p className="text-sm text-gray-600 mb-3">
//         <span className="font-medium">Provider:</span> {course.Provider}
//       </p>

//       <p className="text-sm text-gray-600 mb-3">
//         <span className="font-medium">Skill:</span> {course.Skill}
//       </p>

//       <p className="text-sm text-gray-700">{course.Description}</p>
//     </div>
//   );
// };

// // ✅ Mock data for testing
// export default function Page() {
//   const mockCourses: Course[] = [
//     {
//       Title: "Complete Machine Learning & Data Science Bootcamp 2023",
//       Provider: "Udemy",
//       URL: "https://www.udemy.com/course/complete-machine-learning-data-science-bootcamp-2023/",
//       Description:
//         "This course will enhance your skills in machine learning and data science, which are highly relevant to NLP and data analysis.",
//       Skill: "Machine Learning, Data Science, NLP",
//     },
//     {
//       Title: "Software Architecture & Design",
//       Provider: "Coursera",
//       URL: "https://www.coursera.org/specializations/software-architecture",
//       Description:
//         "Learn how to design and build robust and scalable applications with this Coursera specialization.",
//       Skill: "Software Architecture, Design Patterns",
//     },
//   ];

//   return (
//     <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
//       {mockCourses.map((course, index) => (
//         <CourseCard key={index} course={course} />
//       ))}
//     </div>
//   );
// }

// "use client";

// import * as React from "react";
// import { Badge } from "@/app/components/ui/Badge";
// import { ExternalLink } from "lucide-react";
// import { useGetSuggestionsQuery } from "@/lib/redux/api/cvApi";

// interface Course {
//   Title: string;
//   Provider: string;
//   URL: string;
//   Description: string;
//   Skill: string;
// }

// const CourseCard: React.FC<{ course: Course }> = ({ course }) => {
//   return (
//     <div className="bg-[#F3F5F9] rounded-lg shadow-md p-6 transition-shadow hover:shadow-lg">
//       <div className="flex items-start justify-between mb-3">
//         <Badge
//           variant="outline"
//           className="mb-2 bg-white text-black border-gray-300 shadow-sm"
//         >
//           Online Course
//         </Badge>

//         <a
//           href={course.URL}
//           target="_blank"
//           rel="noopener noreferrer"
//           className="inline-flex items-center gap-1 rounded-full bg-white text-gray-800 px-3 py-1 text-sm font-medium shadow-md hover:shadow-lg hover:bg-gray-100 transition"
//         >
//           <ExternalLink className="h-3 w-3" />
//           View Resource
//         </a>
//       </div>

//       <h3 className="text-lg font-semibold text-gray-900 mb-2 leading-snug">
//         {course.Title}
//       </h3>

//       <p className="text-sm text-gray-600 mb-2">
//         <span className="font-medium">Provider:</span> {course.Provider}
//       </p>

//       <p className="text-sm text-gray-600 mb-2">
//         <span className="font-medium">Skill:</span> {course.Skill}
//       </p>

//       <p className="text-sm text-gray-700">{course.Description}</p>
//     </div>
//   );
// };

// export default function Page() {
//   const { data, error, isLoading } = useGetSuggestionsQuery();

//   if (isLoading) {
//     return <p className="p-6">Loading suggestions...</p>;
//   }

//   // Handle 404 error (No CV found)
//   if (error && "status" in error && error.status === 404) {
//     return (
//       <div className="p-6 text-center">
//         <h2 className="text-xl font-semibold text-gray-800 mb-2">
//           No CV Found
//         </h2>
//         <p className="text-gray-600 mb-4">
//           Please upload your CV first to get personalized course suggestions.
//         </p>
//         {/* You can add a button/link to the CV upload page */}
//       </div>
//     );
//   }

//   // Handle other errors
//   if (error) {
//     return (
//       <p className="p-6 text-red-600">
//         Failed to load suggestions. Please try again later.
//       </p>
//     );
//   }

//   // ✅ Render suggestions
//   const courses: Course[] = data?.data?.suggestions?.Courses ?? [];

//   return (
//     <div className="p-6 grid grid-cols-1 gap-6">
//       {courses.map((course, index) => (
//         <CourseCard key={index} course={course} />
//       ))}
//     </div>
//   );
// }

"use client";

import * as React from "react";
import { ArrowLeft, ExternalLink } from "lucide-react";
import { Badge } from "@/app/components/ui/Badge";
import { useGetSuggestionsQuery } from "@/lib/redux/api/cvApi";
import Link from "next/link";

interface Course {
  Title: string;
  Provider: string;
  URL: string;
  Description: string;
  Skill: string;
}

const CourseCard: React.FC<{ course: Course }> = ({ course }) => {
  return (
    <div className="bg-gradient-to-br from-[#f3fdf369] to-[#056e212a] rounded-2xl shadow-md p-6 transition-shadow hover:shadow-lg">
      <div className="flex items-start justify-between mb-3">
        <Badge className="mb-2 bg-[#23848d6b] text-white  ">
          Online Course
        </Badge>

        <a
          href={course.URL}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-flex items-center gap-1 rounded-full bg-slate-100 text-gray-800 px-3 py-1 text-sm font-medium shadow-md hover:shadow-lg hover:bg-gray-100 transition"
        >
          <ExternalLink className="h-3 w-3" />
          View Resource
        </a>
      </div>

      <h3 className="text-lg font-semibold text-slate-700 mb-2 leading-snug">
        {course.Title}
      </h3>

      <p className="text-sm text-gray-600 mb-2">
        <span className="font-medium">Provider:</span> {course.Provider}
      </p>

      <p className="text-sm text-gray-600 mb-2">
        <span className="font-medium">Skill:</span> {course.Skill}
      </p>

      <p className="text-sm text-slate-700">{course.Description}</p>
    </div>
  );
};

export default function Page() {
  const { data, error, isLoading } = useGetSuggestionsQuery({});

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-b from-green-50 to-blue-50">
        <p className="text-gray-600">Loading suggestions...</p>
      </div>
    );
  }

  if (error && "status" in error && error.status === 404) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-gradient-to-b from-green-50 to-blue-50 px-6 text-center">
        <h2 className="text-xl font-semibold text-gray-800 mb-2">
          No CV Found
        </h2>
        <p className="text-gray-600 mb-4">
          Please upload your CV first to get personalized course suggestions.
        </p>
        <Link
          href="/cv/upload"
          className="bg-white text-gray-800 px-4 py-2 rounded-xl shadow-md hover:shadow-lg transition"
        >
          Upload CV
        </Link>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-b from-green-50 to-blue-50">
        <p className="text-red-600">
          Failed to load suggestions. Please try again later.
        </p>
      </div>
    );
  }

  const courses: Course[] = data?.data?.suggestions?.Courses ?? [];
  const advice: string[] = data?.data?.suggestions?.GeneralAdvice ?? [];

  return (
    <div className="min-h-screen bg-gradient-to-b from-green-50 to-blue-50 py-10 px-6 flex justify-center">
      <div className="w-full max-w-5xl space-y-6">
        {/* Back Button */}
        <div>
          <Link
            href="/dashboard"
            className="inline-flex items-center gap-2 text-gray-700 hover:bg-gray-100 px-4 py-2 rounded-lg transition shadow-sm bg-[#ffffff72]"
          >
            <ArrowLeft className="h-5 w-5" />
            <span className="font-medium">Dashboard</span>
          </Link>
        </div>
        <h1 className="text-3xl font-bold text-center text-slate-700">
          Course Suggestions
        </h1>

        {/* Courses & Advice Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {courses.map((course, index) => (
            <CourseCard key={index} course={course} />
          ))}

          {/* General Advice spans full width */}
          {advice.length > 0 && (
            <div className="bg-gradient-to-br from-[#e5fee7c6] to-[#0e772a47] rounded-2xl shadow-md p-6 md:col-span-2">
              <h3 className="text-lg font-semibold text-gray-900 mb-3">
                General Career Advice
              </h3>
              <ul className="list-disc pl-5 space-y-2 text-gray-700 text-sm">
                {advice.map((item, idx) => (
                  <li key={idx}>{item}</li>
                ))}
              </ul>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
