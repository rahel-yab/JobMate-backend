"use client";

type Props = {
  text: string;
};

export default function CVMessage({ text }: Props) {
  return <span className="block">{text}</span>;
}
