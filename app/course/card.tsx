"use client";

import React from "react";
import { ExternalLink } from "lucide-react";

interface CourseResourceProps {
  Title: string;
  Provider: string;
  Skill: string;
  URL: string;
  Description: string;
}

const CourseResourceCard: React.FC<CourseResourceProps> = ({
  Title,
  Provider,
  Skill,
  URL,
  Description,
}) => {
  return (
    <div className="border rounded-lg p-4 hover:shadow-md transition-shadow mb-4">
      <div className="flex flex-col mb-2">
        <button className="mb-2">Online Course</button>
        <h4 className="font-medium text-gray-900 mb-1">{Title}</h4>
        <p className="text-sm text-gray-600 mb-2">Provider: {Provider}</p>
        <p className="text-sm text-gray-600 mb-2">Skill: {Skill}</p>
        <p className="text-sm text-gray-600">{Description}</p>
      </div>
      <Button
        size="sm"
        variant="outline"
        as="a"
        href={URL}
        target="_blank"
        className="mt-2"
      >
        <ExternalLink className="h-3 w-3 mr-1" />
        View Resource
      </Button>
    </div>
  );
};

export default CourseResourceCard;
