"use client";
import { Jaro } from "next/font/google";
import { FileText, Briefcase, MessageSquare, Lightbulb } from "lucide-react";
import { useLogout } from "@/lib/redux/hooks/useLogout";
import { useRouter } from "next/navigation";

const jaro = Jaro({
  subsets: ["latin"],
  weight: "400",
});

export default function Dashboard() {
  const logout = useLogout();
  const router = useRouter();

  const handleLogout = () => {
    logout(); // clears tokens, resets state, redirects
  };

  const handleRedirect = (path: string) => {
    switch (path) {
      case "cv":
        router.push("/cv");
        break;
      case "jobs":
        router.push("/jobs");
        break;
      case "interview":
        router.push("/interview");
        break;
      case "tips":
        router.push("/tips");
        break;
      default:
        break;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-green-50 to-blue-50 flex flex-col items-center py-10">
      {/* Navbar */}
      <header className="flex justify-end items-center w-full max-w-6xl px-6 mb-12">
        <button
          onClick={handleLogout}
          className="px-3 py-1 text-sm border border-red-500 text-red-600 rounded-md hover:bg-red-50 transition"
        >
          Sign Out
        </button>
      </header>

      {/* Welcome Title */}
      <div className="text-center mb-6">
        <h2 className="text-3xl sm:text-4xl font-bold text-gray-800">
          <span className="font-bold">Welcome to </span>
          <span className={`${jaro.className}`}>
            <span className="text-[#217C6A]">Job</span>
            Mate
          </span>
        </h2>
      </div>

      {/* Subheader */}
      <div className="text-center mb-10">
        <p className="text-lg text-gray-600">
          Your AI-powered career companion for Ethiopian youth
        </p>
        <h2 className="text-xl font-semibold text-green-600 mt-2">
          Hello, Ruth!
        </h2>
        <p className="text-gray-500 mt-1">
          Choose how you'd like to boost your career today:
        </p>
      </div>

      {/* Dashboard Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8 w-full max-w-5xl px-6">
        {/* CV Review */}
        <div
          onClick={() => handleRedirect("cv")}
          className="bg-white p-6 rounded-2xl shadow-md hover:shadow-lg transition text-center cursor-pointer"
        >
          <div className="mb-4 flex justify-center">
            <span className="bg-green-100 p-3 rounded-full">
              <FileText className="w-6 h-6 text-green-600" />
            </span>
          </div>
          <h3 className="text-lg font-semibold text-gray-800">CV Review</h3>
          <p className="text-gray-500 mt-2 text-sm">
            Get AI feedback on your resume and improve your chances
          </p>
        </div>

        {/* Find Jobs */}
        <div
          onClick={() => handleRedirect("jobs")}
          className="bg-white p-6 rounded-2xl shadow-md hover:shadow-lg transition text-center cursor-pointer"
        >
          <div className="mb-4 flex justify-center">
            <span className="bg-green-100 p-3 rounded-full">
              <Briefcase className="w-6 h-6 text-green-600" />
            </span>
          </div>
          <h3 className="text-lg font-semibold text-gray-800">Find Jobs</h3>
          <p className="text-gray-500 mt-2 text-sm">
            Discover local and remote opportunities that match your skills
          </p>
        </div>

        {/* Interview Practice */}
        <div
          onClick={() => handleRedirect("interview")}
          className="bg-white p-6 rounded-2xl shadow-md hover:shadow-lg transition text-center cursor-pointer"
        >
          <div className="mb-4 flex justify-center">
            <span className="bg-green-100 p-3 rounded-full">
              <MessageSquare className="w-6 h-6 text-green-600" />
            </span>
          </div>
          <h3 className="text-lg font-semibold text-gray-800">
            Interview Practice
          </h3>
          <p className="text-gray-500 mt-2 text-sm">
            Practice common questions and get personalized feedback
          </p>
        </div>

        {/* Offline Tips */}
        <div
          onClick={() => handleRedirect("tips")}
          className="bg-white p-6 rounded-2xl shadow-md hover:shadow-lg transition text-center cursor-pointer"
        >
          <div className="mb-4 flex justify-center">
            <span className="bg-green-100 p-3 rounded-full">
              <Lightbulb className="w-6 h-6 text-green-600" />
            </span>
          </div>
          <h3 className="text-lg font-semibold text-gray-800">Offline Tips</h3>
          <p className="text-gray-500 mt-2 text-sm">
            Learn strategies and advice you can apply anytime, even without
            internet
          </p>
        </div>
      </div>
    </div>
  );
}
