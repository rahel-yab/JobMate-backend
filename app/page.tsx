"use client";
import { Jaro, Roboto } from "next/font/google";
import NavBar from "./components/NavBar";
import { Button } from "./components/ui/Button";
import Image from "next/image";
import ServiceComp from "./components/home/ServiceComp";
import { FiBriefcase, FiFileText, FiUser } from "react-icons/fi";
import { AiOutlineRead } from "react-icons/ai";
import { useLanguage } from "@/providers/language-provider";
import { useRouter } from "next/navigation";
import Link from "next/link";

const roboto = Roboto({
  weight: "400",
});
const jaro = Jaro({
  subsets: ["latin"],
  weight: ["400"],
});

const Intro = () => {
  const { t } = useLanguage();
  const router = useRouter();

  const handleRegister = () => {
    router.push("/register"); // Redirect to /register page
  };

  return (
    <section
      id="home"
      className="flex flex-col md:flex-row items-center justify-between 2xl:px-10 px-6 py-12 gap-8 max-w-7xl "
    >
      <div className="md:w-4/5 space-y-6">
        <h1 className="text-2xl md:text-3xl font-bold leading-snug">
          {t("home_title")}
        </h1>
        <p className="text-gray-600 leading-relaxed">{t("home_description")}</p>
        <Button
          className="bg-[#2CA58D] text-white px-6 py-2 rounded-lg shadow-md hover:bg-[#23977e]"
          onClick={handleRegister}
        >
          {t("register")}
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
  const { t } = useLanguage();

  return (
    <section
      id="service"
      className="flex flex-col items-center 2xl:px-10 px-6 py-12 max-w-7xl"
    >
      <h1 className="text-2xl md:text-3xl font-bold leading-snug py-4">
        {t("service_title")}
      </h1>
      <div className="flex flex-wrap gap-4 justify-center">
        <ServiceComp
          icon={<FiFileText className="text-black bg-[#98ff7015] rounded-sm" />}
          name={t("cv_feedback_title")}
          description={t("cv_feedback_desc")}
          link="/chat/cv"
        />
        <ServiceComp
          icon={
            <FiBriefcase className="text-black bg-[#98ff7015] rounded-sm" />
          }
          name={t("job_title")}
          description={t("job_desc")}
          link="/chat/jobsearch"
        />
        <ServiceComp
          icon={<FiUser className="text-black bg-[#98ff7015] rounded-sm" />}
          name={t("interview_title")}
          description={t("interview_desc")}
          link="/chat/interview"
        />
        <ServiceComp
          icon={
            <AiOutlineRead className="text-black bg-[#98ff7015] rounded-sm" />
          }
          name={t("offline_title")}
          description={t("offline_desc")}
          link="/offline_tips"
        />
      </div>
    </section>
  );
};

const Footer = () => {
  const { t } = useLanguage();

  return (
    <div className="p-6 text-center text-gray-400 text-xs">
      <Link href="#home">
        <h1
          className={`${jaro.className}  2xl:text-3xl text-2xl text-gray-400 py-3`}
        >
          <span className="font-jaro text-[#217C6A]">Job</span>Mate
        </h1>
      </Link>
      <p>{t("footer_copyright")}</p>
      <p>{t("footer_rights")}</p>
    </div>
  );
};

export default function Home() {
  return (
    <div
      className={`${roboto.className} text-sm flex flex-col items-center bg-white text-black`}
    >
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
