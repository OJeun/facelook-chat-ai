import OpenAI from "openai";
import {
  Chat,
  AnalysisResult,
  EmojiGenerationResult,
  FullAnalysisResult,
} from "../models/chat";
import { chatOne, chatTwo, chatThree } from "../constants/testData";
import "dotenv/config";

const exampleResult: AnalysisResult = {
  chatId: "111",
  addAchievementScores: [
    { userId: "1", score: 5 },
    { userId: "2", score: 5 },
    { userId: "3", score: 5 },
  ],
  sentimentScores: [
    { score: 8, userId: "1" },
    { score: 8, userId: "2" },
    { score: 8, userId: "3" },
  ],
};

const exampleEmojiResult: EmojiGenerationResult[] = [
  {
    emoji: "🤣", // This is a string containing one Unicode character
    userId: "11",
  },
  {
    emoji: "😐",
    userId: "22",
  },
];

const openai = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

async function generateEmoji(chat: Chat): Promise<EmojiGenerationResult[]> {
  try {
    const completion = await openai.chat.completions.create({
      messages: [
        {
          role: "system",
          content: `You are an expert emotion analyzer specialized in converting chat messages into the most appropriate emojis.
Rules:
- Generate exactly one emoji per user
- Each emoji should reflect the user's dominant emotion
- Consider word choice, tone, and context in your analysis
- Prefer commonly used, easily understood emojis
- Focus on emotional state rather than actions or objects`,
        },
        {
          role: "user",
          content: `Analyze the following chat and generate one emoji for each user:
${JSON.stringify(chat, null, 2)}

Requirements:
1. Return the result strictly in this JSON format:
${JSON.stringify(exampleEmojiResult, null, 2)}
2. Response must be a single array
3. Do not include any explanatory text
4. Each user object must contain 'emoji' and 'userId' fields
5. The 'emoji' field must be a single Unicode emoji character`,
        },
      ],
      model: "gpt-4",
      temperature: 0.6,
      max_tokens: 100,
    });

    // console.log(completion.choices[0].message.content);

    const response = JSON.parse(completion.choices[0].message.content || "[]");
    return Array.isArray(response) ? response : [];
  } catch (error) {
    console.error("Error generating emoji:", error);
    throw error;
  }
}

async function analyzeChatSentiment(chat: Chat): Promise<AnalysisResult> {
  try {
    const completion = await openai.chat.completions.create({
      messages: [
        {
          role: "system",
          content: `You are a sentiment analysis assistant. 
          `,
        },
        {
          role: "user",
          content: `
          Your task is to analyze a given chat conversation and calculate new sentiment scores for each user based on their communication. For each user, compare the old sentiment score with the new score, which should be based on their messages in the conversation. Follow these steps:
          1. Calculate New Sentiment Scores: Based on the messages exchanged in the conversation, assess the sentiment of each user and assign a new sentiment score ranging from 1 to 10. 
          2. Compare the Scores: For each user, compare their new sentiment score with their original score. If the user's sentiment score has improved or remained in the positive range (both old and new scores are 8-10), proceed to step 3.
          3. Assign Achievement Scores: If a user's sentiment improves or remains positive (scores 8-10), assign achievement scores to other users based on their positive impact on the conversation. The scores should range from 0 to 5, depending on how positively they influenced the conversation (for example, being supportive, engaging, or suggesting a fun idea). If a user has no positive impact, the achievement score should be 0.
          `,
        },
        {
          role: "assistant",
          content:
            "I can definitely help with that! Please provide me with the chat conversation you'd like me to analyze for sentiment.",
        },
        {
          role: "user",
          content: `Here is the chat conversation: ${JSON.stringify(
            chat
          )}. Please remember to organize your response like ${JSON.stringify(
            exampleResult
          )} in JSON format all keys should be the same. The response is one single JSON without any extra text.`,
        },
      ],
      model: "gpt-3.5-turbo",
      temperature: 0.7,
    });

    // console.log(completion.choices[0].message.content);

    const response = JSON.parse(completion.choices[0].message.content || "{}");

    return {
      chatId: chat.id.toString(),
      sentimentScores: response.sentimentScores || [],
      addAchievementScores: response.addAchievementScores || [],
    };
  } catch (error) {
    console.error("Error analyzing chat:", error);
    throw error;
  }
}

async function analyzeAllChats() {
  const chats = [chatOne, chatTwo, chatThree];
  const results: AnalysisResult[] = [];

  for (const chat of chats) {
    let success = false;
    while (!success) {
      try {
        const result = await analyzeChatSentiment(chat);
        const emojiResult = await generateEmoji(chat);
        const fullResult: FullAnalysisResult = {
          ...result,
          emojis: emojiResult,
        };
        console.log("fullResult: ", fullResult);
        results.push(fullResult);
        console.log(`analysis complete - chatId: ${chat.id}`);
        success = true; // success flag
      } catch (error) {
        console.error(`Attempt failed for chatId: ${chat.id}`, error);
        await new Promise((resolve) => setTimeout(resolve));
        console.log(`Retrying analysis for chatId: ${chat.id}...`);
      }
    }
  }

  return results;
}

export { analyzeAllChats, analyzeChatSentiment };
