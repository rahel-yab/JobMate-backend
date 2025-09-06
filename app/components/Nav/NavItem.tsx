"use client";

import Link from "next/link";
import { ReactNode } from "react";

interface NavItemProps {
  href: string;
  icon: ReactNode;
  label: string;
  onClick?: () => void;
}

const NavItem = ({ href, icon, label, onClick }: NavItemProps) => {
  return (
    <Link
      href={href}
      onClick={onClick}
      className="flex items-center gap-3 px-4 py-2 text-lg text-gray-800 hover:bg-green-50 rounded-md"
    >
      {icon}
      <span>{label}</span>
    </Link>
  );
};

export default NavItem;
