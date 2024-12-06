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

// 添加新的 Redis key 来存储最后检查时间
const LAST_CHECK_KEY = "lastAiAnalysisCheck";

// execute every 10 seconds
setInterval(async () => {
  try {
    // 1. 获取上次检查时间
    let lastCheckTime = await redisClient.get(LAST_CHECK_KEY);
    const currentTime = new Date().toISOString();

    // 如果没有上次检查时间，使用10秒前的时间
    if (!lastCheckTime) {
      const tenSecondsAgo = new Date(Date.now() - 10000).toISOString();
      lastCheckTime = tenSecondsAgo;
    }

    // 2. 获取所有群组ID
    const groupIds = await redisClient.keys("group:*:messages");

    // 3. 处理所有群组的聊天数据，只分析指定时间范围内的消息
    const chatPromises = groupIds.map(async (groupKey) => {
      const groupId = groupKey.split(":")[1];

      // 获取时间范围内的消息
      const messages = await getMessagesBetweenTimestamps(
        groupId,
        lastCheckTime,
        currentTime
      );

      if (messages.length === 0) {
        return null;
      }

      const userIds: any[] = [];
      const scorePromises = messages.map(async (msg) => {
        const userId = msg.senderId;
        if (!userIds.includes(userId)) {
          userIds.push(userId);
          const score = await sendQueryToDB(
            `SELECT userSentimentScore FROM userGroup WHERE userId = ${msg.senderId} AND groupId = ${groupId};`
          );
          return {
            userId: userId,
            score: score && score[0] ? score[0].userSentimentScore : 0,
          };
        }
        return null;
      });

      // 等待所有分数查询完成
      const scores = (await Promise.all(scorePromises)).filter(
        (score) => score !== null && score.userId !== null
      );

      return {
        id: parseInt(groupId),
        messages: messages
          .filter((msg) => msg.senderId !== null)
          .map((msg) => ({
            message: msg.content,
            userId: msg.senderId,
            messageId: msg.id,
          })),
        sentimentScores: scores,
      };
    });

    // 4. 等待所有聊天数据处理完成并过滤掉空值
    const chats = (await Promise.all(chatPromises)).filter(
      (chat): chat is Chat => chat !== null
    );

    // 5. 只有在有聊天数据时才执行AI分析
    if (chats.length > 0) {
      const AiResults: FullAnalysisResult[] = await analyzeAllChats(chats);

      AiResults.forEach(async (result) => {
        const groupId = result.chatId;
        // broadcast emoji first
        if (connectedClients[groupId]) {
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

        for (const scoreObj of result.sentimentScores) {
          try {
            // 获取用户原始成就点数
            const originalAchievementPointObj = await sendQueryToDB(
              `SELECT achievementPoint FROM user WHERE userId = ${scoreObj.userId};`
            );

            // 检查查询结果是否有效
            if (
              !originalAchievementPointObj ||
              !originalAchievementPointObj[0]
            ) {
              console.error(
                `No achievement point found for user ${scoreObj.userId}`
              );
              continue;
            }

            const originalAchievementPoint =
              originalAchievementPointObj[0].achievementPoint || 0;

            // 更新用户成就点数
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

            // 更新用户情感分数
            await sendQueryToDB(
              `UPDATE userGroup 
               SET userSentimentScore = ${Number(scoreObj.score).toFixed(1)} 
               WHERE userId = ${scoreObj.userId} AND groupId = ${groupId};`
            );

            console.log(
              `Updated user ${scoreObj.userId}'s sentiment score to ${scoreObj.score} in group ${groupId}`
            );
          } catch (error) {
            console.error(
              `Error processing score for user ${scoreObj.userId}:`,
              error
            );
            continue;
          }
        }
      });
    }

    // 6. 更新最后检查时间
    await redisClient.set(LAST_CHECK_KEY, currentTime);
  } catch (error) {
    console.error("Error during AI analysis:", error);
  }
}, 10000);
