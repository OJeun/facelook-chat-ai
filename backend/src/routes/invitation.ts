import { FastifyInstance } from "fastify";
import axios from "axios";
import { errorHandler } from "../services/dbErrorHandler";

interface Invitation {
  receiverId: number;
  senderId: number;
  groupId: number;
}

export async function invitationRoutes(fastify: FastifyInstance) {
  fastify.post<{ Body: Invitation }>(
    "/invitation/send",
    {
      schema: {
        tags: ["invitation"],
        description: "Send invitation",
        security: [{ bearerAuth: [] }],
        body: {
          type: "object",
          required: ["receiverId", "senderId", "groupId"],
          properties: {
            receiverId: { type: "number" },
            senderId: { type: "number" },
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
        const response = await axios.post(
          process.env.DB_API_URL + "api/invitation/send",
          request.body
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );

  fastify.get<{ Params: { userId: string } }>(
    "/invitation/:receiverId",
    {
      schema: {
        tags: ["invitation"],
        description: "Get all invitations by userId",
        security: [{ bearerAuth: [] }],
        params: {
          type: "object",
          required: ["userId"],
          properties: {
            userId: { type: "string" },
          },
        },
        response: {
          200: {
            type: "object",
            properties: {
              invitations: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    invitationId: { type: "number" },
                    senderId: { type: "number" },
                    senderName: { type: "string" },
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
          process.env.DB_API_URL + `api/invitation/${request.params.userId}`
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );

  fastify.post<{ Body: { invitationId: number } }>(
    "/invitation/accept",
    {
      schema: {
        tags: ["invitation"],
        description: "Accept invitation",
        security: [{ bearerAuth: [] }],
        body: {
          type: "object",
          required: ["invitationId"],
          properties: {
            invitationId: { type: "number" },
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
          process.env.DB_API_URL + "api/invitation/accept",
          request.body
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );

  fastify.post<{ Body: { invitationId: number } }>(
    "/invitation/reject",
    {
      schema: {
        tags: ["invitation"],
        description: "Reject invitation",
        security: [{ bearerAuth: [] }],
        body: {
          type: "object",
          required: ["invitationId"],
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
          process.env.DB_API_URL + "api/invitation/reject",
          request.body
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );
}
