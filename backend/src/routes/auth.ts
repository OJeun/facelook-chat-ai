import { FastifyInstance } from "fastify";
import axios from "axios";
import dotenv from "dotenv";
import { errorHandler } from "../services/dbErrorHandler";

dotenv.config();

interface RegisterRequest {
  email: string;
  password: string;
  name: string;
}

interface LoginRequest {
  email: string;
  password: string;
}

export async function authRoutes(fastify: FastifyInstance) {
  fastify.post<{ Body: RegisterRequest }>(
    "/auth/register",
    {
      schema: {
        tags: ["auth"],
        description: "Register a new user",
        body: {
          type: "object",
          required: ["email", "password", "name"],
          properties: {
            email: { type: "string", format: "email" },
            password: { type: "string", minLength: 6 },
            name: { type: "string", minLength: 2 },
          },
        },
        response: {
          200: {
            type: "object",
            properties: {
              message: { type: "string" },
              user: {
                type: "object",
                properties: {
                  userId: { type: "number" },
                  email: { type: "string" },
                  name: { type: "string" },
                  updatedAt: { type: "string" },
                  createdAt: { type: "string" },
                },
              },
            },
          },
        },
      },
    },
    async (request) => {
      try {
        const response = await axios.post(
          process.env.DB_API_URL + "api/auth/register",
          request.body
        );
        return response.data;
      } catch (error) {
        errorHandler(
          error,
          "register failed, please check if your email is already in use"
        );
      }
    }
  );

  fastify.post<{ Body: LoginRequest }>(
    "/auth/login",
    {
      schema: {
        tags: ["auth"],
        description: "Login user",
        body: {
          type: "object",
          required: ["email", "password"],
          properties: {
            email: { type: "string", format: "email" },
            password: { type: "string" },
          },
        },
        response: {
          200: {
            type: "object",
            properties: {
              token: { type: "string" },
              message: { type: "string" },
              userId: { type: "string" },
            },
          },
        },
      },
    },
    async (request, reply) => {
      try {
        const response = await axios.post(
          process.env.DB_API_URL + "api/auth/login",
          request.body
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );
}
