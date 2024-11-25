import { FastifyInstance } from "fastify";
import {
  saveMessagesToDB,
  getMessagesFromDB,
} from "../services/databaseService";
import { getRecentMessages } from "../redis/message";

export function registerChatRoutes(server: FastifyInstance) {
  server.post("/api/chat/saveChats", async (request, response) => {
    const { groupId, chatList } = request.body as any;

    try {
      await saveMessagesToDB(groupId, chatList);
      response.send({ success: true });
    } catch (error) {
      response
        .status(500)
        .send({ success: false, message: "Failed to save chats" });
    }
  });

  server.get("/api/chat/getChats", async (request, reply) => {
    const { groupId, offset, limit } = request.query as {
      groupId: string;
      offset: string;
      limit: string;
    };
    const parsedOffset = parseInt(offset, 10) || 0;
    const parsedLimit = parseInt(limit, 10) || 20;

    const recentMessages = await getRecentMessages(groupId, parsedLimit);
    const recentCount = recentMessages.length;

    if (recentCount >= parsedLimit) {
      return reply.send({ messages: recentMessages });
    }

    const remaining = parsedLimit - recentCount;

    try {
      const olderMessages = await getMessagesFromDB(
        groupId,
        parsedOffset,
        remaining
      );
      reply.send({ messages: [...olderMessages, ...recentMessages] });
    } catch (error) {
      reply
        .status(500)
        .send({ success: false, message: "Failed to retrieve chats" });
    }
  });
}
