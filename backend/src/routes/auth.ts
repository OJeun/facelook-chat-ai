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
    async (request, reply) => {
      try {
        const response = await axios.post(
          process.env.DB_API_URL + "api/auth/register",
          request.body
        );
        return response.data;
      } catch (error) {
        errorHandler(error, reply);
      }
    }
  );

  fastify.post<{ Body: LoginRequest }>(
    "/auth/login",
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
