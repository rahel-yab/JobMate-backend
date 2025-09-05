import { Jaro, Roboto } from "next/font/google";
import NavBar from "./components/NavBar";
import { Button } from "./components/ui/Button";
import Image from "next/image";
import ServiceComp from "./components/home/ServiceComp";
import {
  FiBriefcase,
  FiFileText,
  FiMessageSquare,
  FiUser,
} from "react-icons/fi";
import { AiOutlineRead } from "react-icons/ai";

const roboto = Roboto({
  weight: "400",
});
const jaro = Jaro({
  subsets: ["latin"],
  weight: ["400"],
});
const Intro = () => {
  return (
    <section
      id="home"
      className="flex flex-col md:flex-row items-center justify-between 2xl:px-10 px-6 py-12 gap-8 max-w-7xl "
    >
      <div className="md:w-4/5 space-y-6">
        <h1 className="text-2xl md:text-3xl font-bold leading-snug">
          You don’t have to job-hunt alone
        </h1>
        <p className="text-gray-600 leading-relaxed">
          Finding a job can feel overwhelming — from writing the perfect CV to
          preparing for tough interview questions.{" "}
          <span className="font-semibold">JobMate</span> is your AI-powered
          career buddy, built for Ethiopian youth. It reviews your CV,
          highlights skills you need to grow, and suggests both local and remote
          opportunities. You can even practice real interview questions and get
          instant feedback, in Amharic or English. With JobMate by your side,
          you’ll gain the confidence and guidance you need to land your first
          role, grow your career, and unlock global opportunities.
        </p>
        <Button className="bg-[#2CA58D] text-white px-6 py-2 rounded-lg shadow-md hover:bg-[#23977e]">
          Register
        </Button>
      </div>

      <div className="flex justify-center">
        <Image
          src="/intro.jpg"
          alt="intro picture"
          width={500}
          height={400}
          className="rounded-sm object-cover"
          priority
        />
      </div>
    </section>
  );
};
const Service = () => {
  return (
    <section
      id="service"
      className="flex flex-col items-center 2xl:px-10 px-6 py-12 max-w-7xl"
    >
      <h1 className="text-2xl md:text-3xl font-bold leading-snug py-4">
        JobMate Service
      </h1>
      <div className="flex flex-wrap gap-4">
        <ServiceComp
          icon={<FiFileText className="text-black bg-[#98ff7015] rounded-sm" />}
          name="CV Feedback"
          description="Get instant feedback on your CV, discover strengths, and identify areas to improve."
        />
        <ServiceComp
          icon={
            <FiBriefcase className="text-black bg-[#98ff7015] rounded-sm" />
          }
          name="Available Job "
          description="Find local, remote, and freelance opportunities tailored to your skills and goals."
        />
        <ServiceComp
          icon={<FiUser className="text-black bg-[#98ff7015] rounded-sm" />}
          name="Interview Practice"
          description="Practice common interview questions with AI and get real-time feedback. Learn tips on salary negotiation, workplace culture, and more."
        />
        <ServiceComp
          icon={
            <AiOutlineRead className="text-black bg-[#98ff7015] rounded-sm" />
          }
          name="Offline Resources"
          description="Even without internet, access stored interview tips, CV templates, and job search guides."
        />
        <ServiceComp
          icon={
            <FiMessageSquare className="text-black bg-[#98ff7015] rounded-sm" />
          }
          name="Chat Assistance"
          description="Get quick answers to your questions through a friendly AI chat, making learning and problem-solving easier anytime."
        />
      </div>
    </section>
  );
};
const Footer = () => {
  return (
    <div className="p-6 text-center text-gray-400 text-xs">
      <h1
        className={`${jaro.className}  2xl:text-3xl text-2xl text-gray-400 py-3`}
      >
        <span className="font-jaro text-[#217C6A]">Job</span>Mate
      </h1>
      <p>Copyright © 2020 Nexcent ltd.</p>
      <p>All rights reserved</p>
    </div>
  );
};
export default function Home() {
  return (
    <div className={`${roboto.className} text-sm flex flex-col items-center`}>
      <div className="w-full bg-[#f6f6f6] flex flex-col items-center">
        <NavBar />
        <Intro />
      </div>
      <Service />
      <div className="w-full bg-[#1f2220f8] flex flex-col items-center">
        <Footer />
      </div>
    </div>
  );
}
