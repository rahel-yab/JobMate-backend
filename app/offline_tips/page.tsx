"use client";
// import Header from "../components/header";
import Nav from "../components/Nav/Nav";
import Main from "../components/offline_tips/main";
export default function Offline() {
  return (
    <div>
      {/* <Header /> */}
      <Nav />
      <div className="ml-16">
        <Main />
      </div>
    </div>
  );
}
