import { redisClient } from "./client";
import { redisMessage, redisMessageWithTimeStamp } from "../models/chat";
import { getMessagesFromDB } from "../services/databaseService";
import { Chat, AiAnalysisResult, FullAnalysisResult } from "../models/chat";
import { analyzeAllChats } from "../services/openai";
import { sendQueryToDB } from "../services/databaseService";

// Save a message to the group's message list
export async function saveMessage(message: redisMessage) {
  const messageData: redisMessageWithTimeStamp = {
    ...message,
    createdAt: new Date().toISOString(),
  };

  await redisClient.rPush(
    `group:${message.groupId}:messages`,
    JSON.stringify(messageData)
  );
}

export async function getRecentMessages(
  groupId: string
): Promise<redisMessageWithTimeStamp[]> {
  const limit = 20;

  const messagesFromRedis = await redisClient.lRange(
    `group:${groupId}:messages`,
    -limit,
    -1
  );
  const numberOfMessagesFromRedis = messagesFromRedis.length;

  if (numberOfMessagesFromRedis >= limit) {
    console.log(
      `Redis has enough messages! Retrieved ${numberOfMessagesFromRedis} messages from Redis`
    );
    return messagesFromRedis.map((msg: any) => JSON.parse(msg));
  }

  const numberOfMessagesFromDb = limit - numberOfMessagesFromRedis;

  console.log(
    `Redis does not have enough messages. Retrieving ${numberOfMessagesFromDb} messages from DB...`
  );

  const messagesFromDb = await getMessagesFromDB(
    groupId,
    0,
    numberOfMessagesFromDb
  );

  const lengthOfMessagesFromDb = messagesFromDb.length;

  if (lengthOfMessagesFromDb === 0) {
    console.log(`No messages found in DB for group ${groupId}`);
    return messagesFromRedis.map((msg: any) => JSON.parse(msg));
  }

  if (lengthOfMessagesFromDb === 0 && numberOfMessagesFromRedis === 0) {
    console.log(`No messages found in Redis or DB for group ${groupId}`);
    return [];
  }

  const allMessages = [
    ...messagesFromRedis.map((msg: any) => JSON.parse(msg)),
    ...messagesFromDb,
  ];

  console.log(
    `Combined ${allMessages.length} messages (Redis + MySQL) for group ${groupId}`
  );

  return allMessages;
}

export async function getRecentMessagesFromRedis(groupId: string) {
  const messagesFromRedis = await redisClient.lRange(
    `group:${groupId}:messages`,
    0,
    -1
  );

  if (messagesFromRedis.length > 0) {
    console.log(`!!!!!Raw messages from Redis:`, messagesFromRedis);

    return messagesFromRedis.map((message) => {
      const parsedMessage = JSON.parse(message);

      return {
        ...parsedMessage,
        message: parsedMessage.content,
      };
    });
  }

  return [];
}

export async function getMessagesBetweenTimestamps(
  groupId: string,
  startTime: string,
  endTime: string
): Promise<redisMessageWithTimeStamp[]> {
  // 获取所有消息
  const messagesFromRedis = await redisClient.lRange(
    `group:${groupId}:messages`,
    0,
    -1
  );

  const filteredMessages = messagesFromRedis
    .map((msg) => JSON.parse(msg))
    .filter((msg: redisMessageWithTimeStamp) => {
      const messageTime = new Date(msg.createdAt).getTime();
      const start = new Date(startTime).getTime();
      const end = new Date(endTime).getTime();

      return messageTime >= start && messageTime <= end;
    });

  console.log(
    `Retrieved ${filteredMessages.length} messages between ${startTime} and ${endTime} for group ${groupId}`
  );

  return filteredMessages;
}

export async function clearMessages(groupId: string) {
  await redisClient.del(`group:${groupId}:messages`);
}

// execute every 10 seconds
setInterval(async () => {
  var chats: Chat[] = [];
  try {
    const groupIds = await redisClient.keys("group:*:messages");

    const chatPromises = groupIds.map(async (groupKey) => {
      const groupId = groupKey.split(":")[1];
      const messages = await getRecentMessages(groupId);

      if (messages.length > 0) {
        const scorePromises = messages.map(async (msg) => {
          const userId = msg.senderId;
          const score = await sendQueryToDB(
            `SELECT score FROM users WHERE id = ${userId}`
          );
          return {
            userId: userId,
            score: score[0].score,
          };
        });

        const scores = await Promise.all(scorePromises);

        return {
          id: parseInt(groupId),
          messages: messages.map((msg) => ({
            message: msg.message,
            userId: msg.senderId,
            messageId: msg.chatId,
          })),
          sentimentScores: scores,
        };
      }
      return null;
    });

    // wait for all group chats to be processed
    const completedChats = await Promise.all(chatPromises);
    // filter out null values
    chats = completedChats.filter((chat): chat is Chat => chat !== null);

    const AiResults: FullAnalysisResult[] = await analyzeAllChats(chats);

    AiResults.forEach(async (result) => {
      await saveAiAnalysisResult(result.chatId, result);

      console.log(`AI analysis result saved for group ${result.chatId}`);
    });
  } catch (error) {
    console.error("Error during AI analysis:", error);
  }
}, 10000);

export async function saveAiAnalysisResult(
  groupId: string,
  analysisResult: FullAnalysisResult
): Promise<void> {
  try {
    const aiAnalysisResult: AiAnalysisResult = {
      chatId: groupId,
      analysisResult: analysisResult,
      timestamp: new Date().toISOString(),
    };

    // 保存到 Redis，使用 group:${groupId}:aiAnalysis 作为 key
    await redisClient.set(
      `group:${groupId}:aiAnalysis`,
      JSON.stringify(aiAnalysisResult)
    );

    console.log(`AI analysis result saved for group ${groupId}`);
  } catch (error) {
    console.error(
      `Failed to save AI analysis result for group ${groupId}:`,
      error
    );
    throw error;
  }
}

// get the ai analysis result from redis regardless of the timestamp
export async function getAiAnalysisResult(
  groupId: string
): Promise<AiAnalysisResult | null> {
  try {
    const result = await redisClient.get(`group:${groupId}:aiAnalysis`);
    return result ? JSON.parse(result) : null;
  } catch (error) {
    console.error(
      `Failed to get AI analysis result for group ${groupId}:`,
      error
    );
    return null;
  }
}
