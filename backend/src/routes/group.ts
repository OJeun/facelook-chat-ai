import { FastifyInstance } from "fastify";
import axios from "axios";
import { errorHandler } from "../services/dbErrorHandler";

interface GroupRequest {
  name: string;
  creatorId: string;
}

export async function groupRoutes(fastify: FastifyInstance) {
  fastify.post<{ Body: GroupRequest }>(
    "/invitation/create",
    {
      schema: {
        tags: ["group"],
        description: "Create a new group",
        security: [{ bearerAuth: [] }],
        body: {
          type: "object",
          required: ["name", "creatorId"],
          properties: {
            name: { type: "string" },
            creatorId: { type: "string" },
          },
        },
        response: {
          201: {
            type: "object",
            properties: {
              message: { type: "string" },
              group: {
                type: "object",
                properties: {
                  lastChatId: { type: ["string", "null"] },
                  groupId: { type: "string" },
                  groupName: { type: "string" },
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
          process.env.DB_API_URL + "api/invitation/create",
          request.body
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );

  fastify.get<{ Params: { userId: string } }>(
    "/group/list/:userId",
    {
      schema: {
        tags: ["group"],
        description: "Get user's groups",
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
              groupList: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    groupId: { type: "number" },
                    groupName: { type: "string" },
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
          process.env.DB_API_URL + `api/group/list/${request.params.userId}`
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );

  fastify.get<{ Params: { groupId: number } }>(
    "/group/message/:groupId",
    {
      schema: {
        tags: ["group"],
        description: "Get last message for the group",
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
              message: { type: "string" },
            },
          },
        },
      },
    },
    async (request, reply) => {
      try {
        const response = await axios.get(
          process.env.DB_API_URL + `api/group/message/${request.params.groupId}`
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );
}
