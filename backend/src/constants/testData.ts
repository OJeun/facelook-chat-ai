import { Chat } from "../models/chat";

// this is a test data to give the ai to perform sentiment analysis

export const chatOne: Chat = {
  id: 111,
  messages: [
    { message: "Hey, where should we go for dinner tonight?", userId: "1" },
    { message: "I'm craving sushi, how about a sushi place?", userId: "2" },
    {
      message:
        "Sushi sounds good! But I'm in the mood for something a little heavier. How about Italian?",
      userId: "3",
    },
    {
      message: "Italian is always a good option! Any specific place in mind?",
      userId: "1",
    },
    {
      message:
        "There's that new Italian place downtown. I heard their pasta is amazing!",
      userId: "2",
    },
    {
      message:
        "That sounds great! I could go for some fresh pasta. What about you, 3?",
      userId: "1",
    },
    {
      message:
        "I'm down for that! Maybe we can also get some wine to go with it?",
      userId: "3",
    },
    {
      message: "Wine sounds perfect! Let's do it. What time are we thinking?",
      userId: "1",
    },
    {
      message: "How about 7 PM? Gives us some time to get ready.",
      userId: "2",
    },
    {
      message: "7 PM works for me. Should we make a reservation?",
      userId: "3",
    },
    {
      message: "Yeah, good idea. I'll call them to reserve a table.",
      userId: "1",
    },
    {
      message: "Thanks! I’ll be there at 7. I’m looking forward to the food!",
      userId: "2",
    },
    { message: "Same! I’ve been craving Italian all week.", userId: "3" },
    {
      message: "It's going to be so good! Can't wait to dig into that pasta.",
      userId: "1",
    },
    {
      message: "Do you think they'll have dessert? Maybe some tiramisu?",
      userId: "2",
    },
    {
      message:
        "Tiramisu would be perfect! Definitely getting that for dessert.",
      userId: "3",
    },
    {
      message:
        "I’ll make sure to ask about it when I call. Hope they have some left!",
      userId: "1",
    },
    {
      message: "Sounds like we have everything planned! See you guys at 7!",
      userId: "2",
    },
    { message: "Can't wait! See you all there.", userId: "3" },
    { message: "All set! See you soon!", userId: "1" },
  ],
  sentimentScores: [
    { score: 5, userId: "1" },
    { score: 7, userId: "2" },
    { score: 8, userId: "3" },
  ],
};

export const chatTwo: Chat = {
  id: 112,
  messages: [
    { message: "David, I hate you.", userId: "2" },
    { message: "What did I do?", userId: "3" },
    {
      message: "You better have an idea on what did you do to her.",
      userId: "5",
    },
    { message: "You cheated on me", userId: "2" },
    { message: "This is not true.", userId: "3" },
    { message: "I got evidence. I showed her the proof.", userId: "5" },
    {
      message:
        "David, I need a divorce right now. I can't be with you. Please leave me alone.",
      userId: "2",
    },
  ],
  sentimentScores: [
    { score: 5, userId: "2" },
    { score: 5, userId: "3" },
    { score: 5, userId: "5" },
  ],
};

export const chatThree: Chat = {
  id: 113,
  messages: [
    {
      message:
        "Hey, have you seen that movie we talked about last week? The one with the sad ending?",
      userId: "6",
    },
    {
      message:
        "Yeah, I watched it last night. I didn’t expect to cry that much at the end!",
      userId: "7",
    },
    {
      message:
        "I know, right? I thought it was going to be a regular movie, but that ending really hit hard.",
      userId: "6",
    },
    {
      message:
        "The way they portrayed the character’s struggle, it felt so real. I just couldn’t hold back the tears.",
      userId: "7",
    },
    {
      message:
        "I felt the same! When the main character said goodbye, I lost it. I never thought a movie could make me feel so much.",
      userId: "6",
    },
    {
      message:
        "It’s crazy how a movie can take you on such an emotional ride. I wasn’t prepared for that level of sadness.",
      userId: "7",
    },
    {
      message:
        "Exactly! I didn’t even want to watch something so emotional, but I couldn’t stop myself once I started.",
      userId: "6",
    },
    {
      message:
        "I had to pause it for a moment just to calm down. It was that intense!",
      userId: "7",
    },
    {
      message:
        "Same! I had to take a breather. It felt like my heart was being torn apart.",
      userId: "6",
    },
    {
      message:
        "But even though it was so sad, it was such a beautiful story. I’m glad I watched it, even if I cried at the end.",
      userId: "7",
    },
    {
      message:
        "Yeah, it was a perfect balance of sadness and beauty. It made me reflect on life in such a profound way.",
      userId: "6",
    },
    {
      message:
        "The characters were so well-written. I got so attached to them. Losing them felt like losing a part of me.",
      userId: "7",
    },
    {
      message:
        "It’s rare to find a movie that can make you feel that connected to the characters. It was a masterpiece, despite the tears.",
      userId: "6",
    },
    {
      message:
        "I think that’s what makes it so memorable. I won’t forget that movie for a long time.",
      userId: "7",
    },
    {
      message:
        "Same here. It’ll probably stay with me for a while. But I’m glad we watched it together. It’s nice to share something like that.",
      userId: "6",
    },
    {
      message:
        "Definitely. We should watch more movies like this together. Even if they make us cry, it’s worth it.",
      userId: "7",
    },
    {
      message:
        "Agreed! Next time, though, maybe we should pick something a little less emotional. I need a break from crying!",
      userId: "6",
    },
    {
      message:
        "Haha, yeah, good idea! But it was still worth it. Let’s plan for another movie night soon.",
      userId: "7",
    },
    {
      message: "Looking forward to it! I’ll bring the tissues, just in case.",
      userId: "6",
    },
  ],
  sentimentScores: [
    { score: 5, userId: "6" },
    { score: 5, userId: "7" },
  ],
};
