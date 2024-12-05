import { FastifyInstance } from "fastify";
import axios from "axios";
import { errorHandler } from "../services/dbErrorHandler";

interface FriendRequest {
  userId: string;
  friendId: string;
}

export async function friendRoutes(fastify: FastifyInstance) {
  fastify.post<{ Body: FriendRequest }>(
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

  fastify.post<{ Body: FriendRequest }>(
    "/friend/delete",
    {
      schema: {
        tags: ["friend"],
        description: "Delete a friend",
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
          process.env.DB_API_URL + "api/friend/delete",
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
        description: "Get all user's friends",
        security: [{ bearerAuth: [] }],
        params: {
          type: "object",
          properties: {
            userId: { type: "string" },
          },
        },
        response: {
          200: {
            type: "object",
            properties: {
              friends: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    friendId: { type: "string" },
                    name: { type: "string" },
                    email: { type: "string" },
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
          process.env.DB_API_URL + `api/friend/${request.params.userId}`
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );

  fastify.get<{ Params: { userId: string } }>(
    "/user/:userId",
    {
      schema: {
        tags: ["friend"],
        description: "Get user's info",
        security: [{ bearerAuth: [] }],
        params: {
          type: "object",
          properties: {
            userId: { type: "string" },
          },
        },
        response: {
          200: {
            type: "object",
            properties: {
              user: {
                type: "object",
                properties: {
                  userId: { type: "number" },
                  name: { type: "string" },
                  email: { type: "string" },
                  achievementPoint: { type: "number" },
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
          process.env.DB_API_URL + `api/user/${request.params.userId}`
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );
}
