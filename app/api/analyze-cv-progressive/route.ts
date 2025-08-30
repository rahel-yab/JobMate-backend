import { NextRequest, NextResponse } from "next/server"

// Mock sections to expect
const requiredSections = ["Name", "Experience", "Education", "Skills"]

export async function POST(req: NextRequest) {
  const data = await req.json()
  const messages: { sender: string; content: string }[] = data.messages || []

  // Aggregate all user content
  const userText = messages
    .filter((m) => m.sender === "user")
    .map((m) => m.content.toLowerCase())
    .join(" ")

  // Determine missing sections
  const missingSections = requiredSections.filter(
    (section) => !userText.includes(section.toLowerCase())
  )

  let aiMessage = ""

  if (missingSections.length === 0) {
    // All sections present, give simple feedback
    aiMessage = `✅ All main CV sections received. Here’s a quick feedback:\n- Experience looks good.\n- Education format is clear.\n- Skills are listed.`
  } else {
    // Ask for missing sections
    aiMessage = `💡 Please provide the following missing section(s): ${missingSections.join(
      ", "
    )}`
  }

  return NextResponse.json({ success: true, aiMessage })
}
