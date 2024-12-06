import { FastifyInstance } from "fastify";
import axios from "axios";
import dotenv from "dotenv";
import { errorHandler } from "../services/dbErrorHandler";

dotenv.config();

interface QueryRequest {
  query: string; 
  params?: any[]; 
}

export async function queryRoutes(fastify: FastifyInstance) {
  fastify.post<{ Body: QueryRequest }>(
    "/db/query",
    {
      schema: {
        tags: ["database"],
        description: "Execute any SQL query through the DB service",
        body: {
          type: "object",
          required: ["query"],
          properties: {
            query: { type: "string" },
            params: {
              type: "array",
              items: {
                anyOf: [
                  { type: "string" },
                  { type: "number" },
                  { type: "null" },
                ],
              },
            },
          },
        },
        response: {
          200: {
            type: "object",
            properties: {
              success: { type: "boolean" },
              result: { type: "array" },
            },
          },
        },
      },
    },
    async (request, reply) => {
      try {
        const response = await axios.post(
          process.env.DB_API_URL + "api/db/query",
          request.body
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );
}
