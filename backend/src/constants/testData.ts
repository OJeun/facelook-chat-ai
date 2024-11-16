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
    { message: "How about 7 PM? Gives us some time to get ready.", userId: "2" },
      { message: "7 PM works for me. Should we make a reservation?", userId: "3" },
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
    { message: "David, where were you last night? We were all worried about you.", userId: "2" },
    { message: "Yeah, it’s not okay to be out at a bar at midnight without telling anyone. You could’ve at least given us a heads-up.", userId: "3" },
    { message: "I was out at a bar with some friends. It's no big deal, I didn’t think I needed to update anyone.", userId: "5" },
    { message: "It is a big deal, David. We were worried about you. It's not safe to be out that late without letting someone know.", userId: "2" },
    { message: "We care about you, but this was irresponsible. What if something happened to you? We just want to make sure you're safe.", userId: "3" },
    { message: "You don’t get it. I’m an adult. I don’t need to report every little thing I do.", userId: "5" },
    { message: "David, it’s not about controlling you. We just want to know that you’re okay. It’s about our peace of mind.", userId: "2" },
    { message: "Yeah, we don’t want you to feel like we're being overbearing, but you’ve got to understand why we were so concerned.", userId: "3" },
    { message: "I don't need you guys to lecture me. I know what I’m doing.", userId: "5" },
    { message: "We’re not lecturing you, we’re just saying that we would’ve appreciated a message or something. It’s about safety.", userId: "2" },
    { message: "We don’t want to make you feel bad, but this kind of thing worries us. Can’t you see why we’d feel upset?", userId: "3" },
    { message: "I get it. I should have said something. But I don’t want to be treated like a kid.", userId: "5" },
    { message: "We're not treating you like a kid, David. We’re treating you like someone we care about. It’s just that we were genuinely scared.", userId: "2" },
    { message: "We just want you to be safe. We care about your well-being. We don’t want to make you upset, but we’re really worried.", userId: "3" },
    { message: "Fine, I get it. I should’ve let you know. But you don’t have to make me feel like I’m in trouble for it.", userId: "5" },
    { message: "We’re not trying to make you feel bad, David. We just want to make sure it doesn’t happen again, for your own safety.", userId: "2" },
    { message: "Yeah, we just want to look out for each other. Next time, just let us know where you are, and we won’t worry as much.", userId: "3" },
    { message: "I understand. I’m sorry for making you worry. I’ll be more thoughtful next time.", userId: "5" },
    { message: "Thanks for understanding, David. We’re just glad you’re okay.", userId: "2" },
    { message: "Yeah, we really care about you. Just be safe, okay?", userId: "3" },
  ],
  sentimentScores: [
    { score: 5, userId: "2" },
    { score: 5, userId: "3" },
    { score: 4, userId: "5" },
  ],
};

export const chatThree: Chat = {
  id: 113,
  messages: [
    { message: "Hey, have you seen that movie we talked about last week? The one with the sad ending?", userId: "6" },
    { message: "Yeah, I watched it last night. I didn’t expect to cry that much at the end!", userId: "7" },
    { message: "I know, right? I thought it was going to be a regular movie, but that ending really hit hard.", userId: "6" },
    { message: "The way they portrayed the character’s struggle, it felt so real. I just couldn’t hold back the tears.", userId: "7" },
    { message: "I felt the same! When the main character said goodbye, I lost it. I never thought a movie could make me feel so much.", userId: "6" },
    { message: "It’s crazy how a movie can take you on such an emotional ride. I wasn’t prepared for that level of sadness.", userId: "7" },
    { message: "Exactly! I didn’t even want to watch something so emotional, but I couldn’t stop myself once I started.", userId: "6" },
    { message: "I had to pause it for a moment just to calm down. It was that intense!", userId: "7" },
    { message: "Same! I had to take a breather. It felt like my heart was being torn apart.", userId: "6" },
    { message: "But even though it was so sad, it was such a beautiful story. I’m glad I watched it, even if I cried at the end.", userId: "7" },
    { message: "Yeah, it was a perfect balance of sadness and beauty. It made me reflect on life in such a profound way.", userId: "6" },
    { message: "The characters were so well-written. I got so attached to them. Losing them felt like losing a part of me.", userId: "7" },
    { message: "It’s rare to find a movie that can make you feel that connected to the characters. It was a masterpiece, despite the tears.", userId: "6" },
    { message: "I think that’s what makes it so memorable. I won’t forget that movie for a long time.", userId: "7" },
    { message: "Same here. It’ll probably stay with me for a while. But I’m glad we watched it together. It’s nice to share something like that.", userId: "6" },
    { message: "Definitely. We should watch more movies like this together. Even if they make us cry, it’s worth it.", userId: "7" },
    { message: "Agreed! Next time, though, maybe we should pick something a little less emotional. I need a break from crying!", userId: "6" },
    { message: "Haha, yeah, good idea! But it was still worth it. Let’s plan for another movie night soon.", userId: "7" },
    { message: "Looking forward to it! I’ll bring the tissues, just in case.", userId: "6" },
  ],
  sentimentScores: [
    { score: 5, userId: "6" },
    { score: 5, userId: "7" },
  ],
};