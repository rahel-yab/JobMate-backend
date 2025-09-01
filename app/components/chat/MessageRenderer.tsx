import CVMessage from "./contexts/CVMessage";
// import InterviewMessage from "./InterviewMessage";
// import SkillMessage from "./SkillMessage";
// import JobMessage from "./JobMessage";
import DefaultMessage from "./contexts/DefaultMessage";

export default function MessageRenderer({ message }: { message: any }) {
  switch (message.type) {
    case "cv":
      return (
        <CVMessage
          summary={message.summary}
          strengths={message.strengths}
          weaknesses={message.weaknesses}
          improvements={message.improvements}
        />
      );
    // case "interview":
    //   return <InterviewMessage message={message} />;
    // case "skills":
    //   return <SkillMessage message={message} />;
    // case "job":
    //   return <JobMessage message={message} />;
    default:
      return <DefaultMessage text={message.text} />;
  }
}
