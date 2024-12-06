import { redisClient } from "./client";
import { redisMessage, redisMessageWithTimeStamp } from "../models/chat";
import { getMessagesFromDB } from "../services/databaseService";
import { Chat, FullAnalysisResult } from "../models/chat";
import { analyzeAllChats } from "../services/openai";
import { sendQueryToDB } from "../services/databaseService";
import { connectedClients } from "../sockets/websocket";

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
    ...messagesFromDb,
    ...messagesFromRedis.map((msg: any) => JSON.parse(msg)),
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

      var userIds: any[] = [];

      if (messages.length > 0) {
        const scorePromises = messages.map(async (msg) => {
          const userId = msg.senderId;

          if (!userIds.includes(userId)) {
            userIds.push(userId);
            const score = await sendQueryToDB(
              `SELECT userSentimentScore FROM userGroup WHERE userId = ${msg.senderId} AND groupId = ${groupId};`
            );
            return {
              userId: userId,
              score: score[0].score,
            };
          }
        });

        const scores = await Promise.all(scorePromises);

        return {
          id: parseInt(groupId),
          messages: messages.map((msg) => ({
            message: msg.content,
            userId: msg.senderId,
            messageId: msg.id,
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
      const groupId = result.chatId;
      // broadcast emoji first
      if (connectedClients[groupId]) {
        // Transform emojis into the required format
        const formattedEmojis = result.emojis.map((emojiResult) => ({
          emoji: emojiResult.emoji,
          userId: emojiResult.userId.toString(),
          messageId: emojiResult.messageId.toString(),
        }));

        for (const client of connectedClients[groupId]) {
          if (client.readyState === WebSocket.OPEN) {
            client.send(
              JSON.stringify({
                type: "newEmojis",
                emojis: formattedEmojis,
              })
            );
          }
        }
      }

      result.sentimentScores.forEach(async (scoreObj) => {
        // get user's original achievement point
        const originalAchievementPointObj = await sendQueryToDB(
          `SELECT achievementPoint FROM user WHERE userId = ${scoreObj.userId};`
        );

        const originalAchievementPoint =
          originalAchievementPointObj[0].achievementPoint;

        // update user's achievement point
        await sendQueryToDB(
          `UPDATE user SET achievementPoint = ${
            originalAchievementPoint + scoreObj.achievementScore
          } WHERE userId = ${scoreObj.userId};`
        );
        console.log(
          `Updated user ${
            scoreObj.userId
          }'s achievement point from ${originalAchievementPoint} to ${
            originalAchievementPoint + scoreObj.achievementScore
          }`
        );

        // update user's sentiment score
        await sendQueryToDB(
          `UPDATE userGroup 
           SET userSentimentScore = ${Number(scoreObj.score).toFixed(1)} 
           WHERE userId = ${scoreObj.userId} AND groupId = ${groupId};`
        );
        console.log(
          `Updated user ${scoreObj.userId}'s sentiment score to ${scoreObj.score} in group ${groupId}`
        );
      });
    });
  } catch (error) {
    console.error("Error during AI analysis:", error);
  }
}, 10000);
