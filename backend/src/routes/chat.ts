import { FastifyInstance } from "fastify";
import axios from "axios";
import { errorHandler } from "../services/dbErrorHandler";

interface Chat {
  groupId: number;
  senderId: number;
  message: string;
  createdAt: string;
}

interface ChatListSaveRequest {
  chatList: Chat[];
}

export async function chatRoutes(fastify: FastifyInstance) {
  fastify.post<{ Body: ChatListSaveRequest }>(
    "/chat/saveChats",
    {
      schema: {
        tags: ["chat"],
        description: "Save chat list",
        security: [{ bearerAuth: [] }],
        body: {
          type: "object",
          required: ["chatList"],
          properties: {
            chatList: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  groupId: { type: "number" },
                  senderId: { type: "number" },
                  message: { type: "string" },
                  createdAt: { type: "string" },
                },
              },
            },
          },
        },
        response: {
          200: {
            type: "object",
            properties: {
              chatList: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    chatId: { type: "number" },
                    groupId: { type: "number" },
                    senderId: { type: "number" },
                    message: { type: "string" },
                    createdAt: { type: "string" },
                  },
                },
              },
            },
          },
        },
      },
    },
    async (request, reply) => {
      try {
        const response = await axios.post(
          process.env.DB_API_URL + "api/chat/saveChats",
          request.body
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );

  fastify.get<{ Params: { groupId: number } }>(
    "/chat/20Chats/:groupId",
    {
      schema: {
        tags: ["chat"],
        description: "Get last 20 chats for the group",
        security: [{ bearerAuth: [] }],
        params: {
          type: "object",
          properties: {
            groupId: { type: "number" },
          },
        },
        response: {
          200: {
            type: "object",
            properties: {
              chats: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    chatId: { type: "number" },
                    groupId: { type: "number" },
                    senderId: { type: "string" },
                    message: { type: "string" },
                    createdAt: { type: "string" },
                    userId: { type: ["string", "null"] },
                  },
                },
              },
            },
          },
        },
      },
    },
    async (request, reply) => {
      try {
        const response = await axios.get(
          process.env.DB_API_URL + `api/chat/20Chats/${request.params.groupId}`
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );
}
