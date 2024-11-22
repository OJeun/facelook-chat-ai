import { FastifyInstance } from "fastify";
import axios from "axios";
import { errorHandler } from "../services/dbErrorHandler";

interface AddFriendRequest {
  userId: string;
  friendId: string;
}

export async function friendRoutes(fastify: FastifyInstance) {
  fastify.post<{ Body: AddFriendRequest }>(
    "/friend/add",
    {
      schema: {
        tags: ["friend"],
        description: "Add a new friend",
        security: [{ bearerAuth: [] }],
        body: {
          type: "object",
          required: ["userId", "friendId"],
          properties: {
            userId: { type: "string" },
            friendId: { type: "string" },
          },
        },
        response: {
          200: {
            type: "object",
            properties: {
              message: { type: "string" },
            },
          },
        },
      },
    },
    async (request, reply) => {
      try {
        const response = await axios.post(
          process.env.DB_API_URL + "api/friend/add",
          request.body
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );

  fastify.get<{ Params: { userId: string } }>(
    "/friend/:userId",
    {
      schema: {
        tags: ["friend"],
        description: "Get user's friends",
        security: [{ bearerAuth: [] }],
        params: {
          type: "object",
          properties: {
            userId: { type: "string" },
          },
        },
        response: {
          200: {
            type: "array",
            items: {
              type: "object",
              properties: {
                id: { type: "string" },
                name: { type: "string" },
                email: { type: "string" },
              },
            },
          },
        },
      },
    },
    async (request, reply) => {
      try {
        const response = await axios.get(
          process.env.DB_API_URL + `api/friend/${request.params.userId}`
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );
}
