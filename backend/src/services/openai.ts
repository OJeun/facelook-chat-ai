import OpenAI from "openai";
import {
  Chat,
  AnalysisResult,
  EmojiGenerationResult,
  FullAnalysisResult,
  EmojiWithMessageId,
  UserSentimentScore,
  UserSentimentScoreWithAchievementScore,
  AiResult,
} from "../models/chat";
import "dotenv/config";

const exampleResult: AiResult = {
  chatId: "111",
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

const calculateAchievementScore = (
  newScores: number[],
  oldScores: number[]
): number => {
  let totalAchievementScore = 0;
  newScores.forEach((score, index) => {
    if (score > oldScores[index]) {
      totalAchievementScore += (score - oldScores[index]) * 2;
    } else if (score < oldScores[index] && oldScores[index] - score > 2) {
      totalAchievementScore -= 6;
    } else if (score < oldScores[index] && oldScores[index] - score <= 2) {
      totalAchievementScore -= 3;
    }
  });
  return totalAchievementScore;
};

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
          1. Analysis Sentiment Scores: Based on the messages exchanged in the conversation, assess the sentiment of each user
          2. You do not necessarily change the score if you think there is no change in the sentiment, if the user is already very happy and stay positive, do not change the score
          3. The score range is from 1 to 10
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

    var output: UserSentimentScoreWithAchievementScore[] = [];

    response.sentimentScores.forEach((data: UserSentimentScore) => {
      const userId = data.userId;
      const dataWithAchievementScore: UserSentimentScoreWithAchievementScore = {
        ...data,
        achievementScore: 0,
      };

      // 获取其他用户的新分数
      const otherUsersNewScores: number[] = response.sentimentScores
        .filter((score: UserSentimentScore) => score.userId !== userId)
        .map((score: UserSentimentScore) => Number(score.score));

      // 获取其他用户的旧分数
      const otherUsersOldScores: number[] = chat.sentimentScores
        .filter((score: UserSentimentScore) => score.userId !== userId)
        .map((score: UserSentimentScore) => Number(score.score));

      const achievementScore: number = calculateAchievementScore(
        otherUsersNewScores,
        otherUsersOldScores
      );
      dataWithAchievementScore.achievementScore = achievementScore;
      output.push(dataWithAchievementScore);
      console.log(
        "dataWithAchievementScore for userId: ",
        userId,
        dataWithAchievementScore
      );
    });

    return {
      chatId: chat.id.toString(),
      sentimentScores: output,
    };
  } catch (error) {
    console.error("Error analyzing chat:", error);
    throw error;
  }
}

const getEmojisWithMessageId = (
  emojiResult: EmojiGenerationResult[],
  chat: Chat,
  emojisWithMessageId: EmojiWithMessageId[]
): void => {
  emojiResult.forEach((emoji) => {
    const eachUser = emoji.userId;
    const lastMessageId = chat.messages
      .slice()
      .reverse()
      .find((message) => message.userId === eachUser)?.messageId;

    if (lastMessageId) {
      emojisWithMessageId.push({
        ...emoji,
        messageId: lastMessageId,
      });
    }
  });
};

async function analyzeAllChats(chats: Chat[]) {
  const results: AnalysisResult[] = [];

  for (const chat of chats) {
    let retryCount = 0;
    const maxRetries = 3;
    let success = false;

    while (!success && retryCount < maxRetries) {
      try {
        const result = await analyzeChatSentiment(chat);
        const emojiResult = await generateEmoji(chat);

        const fullResult: FullAnalysisResult = {
          ...result,
          emojis: emojiResult,
        };

        const emojisWithMessageId: EmojiWithMessageId[] = [];
        getEmojisWithMessageId(emojiResult, chat, emojisWithMessageId);
        fullResult.emojis = emojisWithMessageId;
        console.log("fullResult: ", fullResult);
        results.push(fullResult);
        console.log(`analysis complete - chatId: ${chat.id}`);
        success = true;
      } catch (error) {
        retryCount++;
        console.error(
          `Attempt ${retryCount} failed for chatId: ${chat.id}`,
          error
        );
        if (retryCount === maxRetries) {
          throw new Error(
            `Failed to analyze chat ${chat.id} after ${maxRetries} attempts`
          );
        }
        await new Promise((resolve) => setTimeout(resolve, 1000 * retryCount));
        console.log(`Retrying analysis for chatId: ${chat.id}...`);
      }
    }
  }

  return results;
}

export { analyzeAllChats, analyzeChatSentiment };
