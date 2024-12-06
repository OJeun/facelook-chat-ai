import { redisClient } from "./client";
import { redisMessage, redisMessageWithTimeStamp } from "../models/chat";
import { getMessagesFromDB } from "../services/databaseService";

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
    ...messagesFromRedis.map((msg: any) => JSON.parse(msg))
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



export async function clearMessages(groupId: string) {
  await redisClient.del(`group:${groupId}:messages`);
}
