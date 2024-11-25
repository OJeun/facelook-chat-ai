import { FastifyInstance } from "fastify";
import { saveMessage, getMessagesFromDB } from "../services/databaseService";

export function registerChatRoutes(server: FastifyInstance) {
    server.post("/api/chat/saveChats", async (request, response) => {
        const { groupId, chatList } = request.body as any;

        try {
            await saveMessage(groupId, chatList);
            response.send({ success: true });
        } catch (error) {
            response.status(500).send({ success: false, message: "Failed to save chats" });
        }
    });

    server.get("/api/chat/getChats", async (request, reply) => {
        const { groupId, offset, limit } = request.query as { groupId: string, offset: string, limit: string };
        const parsedOffset = parseInt(offset, 10) || 0;
        const parsedLimit = parseInt(limit, 10) || 20;

        try {
            const messages = await getMessagesFromDB(groupId, parsedOffset, parsedLimit);
            reply.send({ success: true, messages });
        } catch (error) {
            reply.status(500).send({ success: false, message: "Failed to retrieve chats" });
        }
    });
}
