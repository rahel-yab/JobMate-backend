import React, { useState } from 'react';
import { tips } from "./tips";
import TipProvider from "./tips_provider";
import { useLanguage } from "@/providers/language-provider";
const styles:string[] = [
                      `px-4 rounded text-sm cursor-pointer`,
                      'bg-gray-200 text-gray-700',
                      'bg-[#217C6A] text-white']
const Main = () => {
  const [activeTab, setActiveTab] = useState('cv');
  const { language, t } = useLanguage(); 
  const renderTips = () => {
    switch (activeTab) {
      case 'cv':
        return <TipProvider tips={tips[language].cv_guide} />;
      case 'interview':
        return <TipProvider tips={tips[language].interviewQuestions} />;
      case 'jobboards':
        return <TipProvider tips={tips[language].jobBoards} />;
      case 'skills':
        return <TipProvider tips={tips[language].skill_enhancements} />;
      case 'insights':
        return <TipProvider tips={tips[language].marketInsights} />;
      case 'motivation':
        return <TipProvider tips={tips[language].motivation_tips} />;
      default:
        return null;
    }  };
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="container mx-auto px-4 py-6">
        <div className="flex flex-wrap shadow-sm p-3 rounded gap-2 mb-8">
         <button                                 
            onClick={() => setActiveTab('cv')}
            className={`${styles[0]}
              ${activeTab === 'cv' ? styles[2] : styles[1]}`}>
            {t("cv_writing")}
          </button>
          <button
            onClick={() => setActiveTab('interview')}
            className={`${styles[0]}
              ${activeTab === 'interview' ? styles[2] : styles[1]}`} >
            {t("interview_prep")}
          </button>
          <button
            onClick={() => setActiveTab('jobboards')}
            className={`${styles[0]}
              ${activeTab === 'jobboards' ? styles[2] : styles[1]}`}>
            {t("job_boards")}
          </button>
          <button
            onClick={() => setActiveTab('skills')}
            className={`${styles[0]}
              ${activeTab === 'skills' ? styles[2] : styles[1]}`}>
            {t("skill_enhancements")}
          </button>
          <button
            onClick={() => setActiveTab('insights')}
            className={`${styles[0]}
              ${activeTab === 'insights' ? styles[2] : styles[1]}`}>
            {t("market_insights")}
          </button>
          <button
            onClick={() => setActiveTab('motivation')}
            className={`${styles[0]}
              ${activeTab === 'motivation' ? styles[2] : styles[1]}`}>
            {t("motivation")}
          </button>
        </div>
        <div className="bg-white rounded-lg p-6">
          {renderTips()}
        </div>
        <div className="mt-8 flex justify-center">
          <a
            href="https://www.canva.com/"
            target="_blank"
            rel="noopener noreferrer"
            className="cursor-pointer bg-[#217C6A] hover:bg-[#1a6152]
             text-white py-3 px-4 rounded-lg font-medium transition-colors text-center">
            {t("start_building")}
          </a>
        </div>
      </div>
      <footer className="bg-[#217C6A]  text-white mt-12 py-6">
        <div className="container mx-auto px-4 text-center">
          <p>{t("your_offline")}</p>
        </div>
      </footer>
    </div>
  );
};
export default Main;