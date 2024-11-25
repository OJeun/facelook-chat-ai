import { redisClient } from "./client";
import { Message, MessageWithTimestamp } from "../models/chat";

// Save a message to the group's message list
export async function saveMessage(message: Message) {
  const messageData: MessageWithTimestamp = {
    ...message,
    createdAt: new Date().toISOString(),
  };

  await redisClient.rPush(
    `group:${message.groupId}:messages`,
    JSON.stringify(messageData)
  );
}

// Retrieve the most recent 20 messages from a group
export async function getRecentMessages(groupId: string, limit: number = 20): Promise<any[]> {
  const messages = await redisClient.lRange(`group:${groupId}:messages`, -limit, -1);
  return messages.map((msg) => JSON.parse(msg));
}

export async function clearMessages(groupId: string) {
  await redisClient.del(`group:${groupId}:messages`);
}
