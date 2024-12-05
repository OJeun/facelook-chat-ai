import { FastifyInstance } from 'fastify';
import axios from 'axios';
import { errorHandler } from '../services/dbErrorHandler';

export async function friendRequestRoutes(fastify: FastifyInstance) {
  fastify.get<{ Params: { receiverId: string } }>(
    '/friend/request/:receiverId',
    {
      schema: {
        tags: ['friendRequest'],
        description: 'Get all pending friend requests for a user',
        security: [{ bearerAuth: [] }],
        params: {
          type: 'object',
          properties: {
            receiverId: { type: 'string' },
          },
        },
        response: {
          200: {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                requestId: { type: 'number' },
                senderId: { type: 'number' },
                senderName: { type: 'string' },
                senderEmail: { type: 'string' },
                status: { type: 'string' },
              },
            },
          },
        },
      },
    },
    async (request, reply) => {
      try {
        const response = await axios.get(
          process.env.DB_API_URL +
            `api/friend/request/${request.params.receiverId}`
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );

  fastify.post<{ Body: { senderId: number; receiverEmail: string } }>(
    '/friend/request/send',
    {
      schema: {
        tags: ['friendRequest'],
        description: 'Send a friend request',
        security: [{ bearerAuth: [] }],
        body: {
          type: 'object',
          required: ['senderId', 'receiverEmail'],
          properties: {
            senderId: { type: 'number' },
            receiverEmail: { type: 'string' },
          },
        },
        response: {
          200: {
            type: 'object',
            properties: {
              status: { type: 'string' },
              message: { type: 'string' },
            },
          },
        },
      },
    },
    async (request, reply) => {
      try {
        const response = await axios.post(
          process.env.DB_API_URL + 'api/friend/request/send',
          request.body
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );

  fastify.post<{ Body: { requestId: number } }>(
    '/friend/request/accept',
    {
      schema: {
        tags: ['friendRequest'],
        description: 'Accept a friend request',
        security: [{ bearerAuth: [] }],
        body: {
          type: 'object',
          required: ['requestId'],
          properties: {
            requestId: { type: 'number' },
          },
        },
        response: {
          200: {
            type: 'object',
            properties: {
              message: { type: 'string' },
            },
          },
        },
      },
    },
    async (request, reply) => {
      try {
        const response = await axios.post(
          process.env.DB_API_URL + 'api/friend/request/accept',
          request.body
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );

  fastify.post<{ Body: { requestId: number } }>(
    '/friend/request/reject',
    {
      schema: {
        tags: ['friendRequest'],
        description: 'Reject a friend request',
        security: [{ bearerAuth: [] }],
        body: {
          type: 'object',
          required: ['requestId'],
          properties: {
            requestId: { type: 'number' },
          },
        },
        response: {
          200: {
            type: 'object',
            properties: {
              message: { type: 'string' },
            },
          },
        },
      },
    },
    async (request, reply) => {
      try {
        const response = await axios.post(
          process.env.DB_API_URL + 'api/friend/request/reject',
          request.body
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );
}
