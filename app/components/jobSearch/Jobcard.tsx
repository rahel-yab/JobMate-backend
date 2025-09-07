import Link from "next/link";
import CategoryItem from "./CategoryItem";
import { FiBriefcase } from "react-icons/fi";

interface JobCardProps {
  id?: string;
  title?: string;
  company?: string;
  location?: string;
  type?: string;
  requirements?: string[];
  link?: string;
  source?: string;
}

const Card = ({
  id,
  title,
  company,
  location,
  type,
  requirements,
  link,
  source,
}: JobCardProps) => {
  const colr = [
    "border-yellow-500 text-yellow-500",
    "border-red-500 text-red-500",
    "border-green-500 text-green-500",
    "border-blue-500 text-blue-500",
    "border-indigo-500 text-indigo-500",
    "border-purple-500 text-purple-500",
    "border-orange-500 text-orange-500",
    "border-sky-500 text-sky-500",
  ];

  return (
    <div className="bg-[#20e65209] shadow-md border border-[#00000010] flex rounded-3xl px-8 py-4 m-2 hover:shadow-lg transition-all duration-200 w-2/3">
      {/* Company Logo Placeholder */}
      <div className="mx-3 shrink-0">
        <FiBriefcase className="text-green-950" size={50} />
      </div>

      {/* Job Info */}
      <div className="px-6 flex flex-col justify-between w-full">
        <div>
          {title && (
            <h2 className="text-lg text-green-950 ">
              {title.charAt(0).toUpperCase() + title.slice(1)}
            </h2>
          )}
          {(company || location) && (
            <p className="text-gray-500">
              {company && company} {company && location && "-"}{" "}
              {location && <span>{location}</span>}
            </p>
          )}
        </div>

        {/* Footer: type, requirements, source, link */}
        <div className="mt-3 flex flex-wrap items-center gap-2">
          {type && (
            <CategoryItem name={type} className="bg-green-50 text-orange-500" />
          )}

          {requirements &&
            requirements?.length > 0 &&
            requirements.map((req, index) => (
              <CategoryItem
                key={`${id || "job"}-req-${index}`}
                name={req}
                className={`border ${
                  colr[Math.floor(Math.random() * colr.length)]
                }`}
              />
            ))}

          {source && (
            <>
              <span className="text-gray-400 mx-2">|</span>
              <CategoryItem
                name={source}
                className="bg-blue-50 text-blue-500"
              />
            </>
          )}

          {link && (
            <Link
              href={link}
              target="_blank"
              className="ml-auto text-blue-600 hover:underline text-sm"
            >
              View Job →
            </Link>
          )}
        </div>
      </div>
    </div>
  );
};

export default Card;
