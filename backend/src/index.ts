// src/index.ts
import fastify, { FastifyInstance, FastifyRequest } from "fastify";
import { authRoutes } from "./routes/auth";
import { friendRoutes } from "./routes/friend";
import { chatRoutes } from "./routes/chat";
import { groupRoutes } from "./routes/group";
import { invitationRoutes } from "./routes/invitation";
import jwt from "jsonwebtoken";
import { JWTPayload } from "./models/server";
// import fastifyWebsocket from "@fastify/websocket";
// import Redis from "ioredis-mock";
// import { WebSocket } from "ws";
import swagger from "@fastify/swagger";
import swaggerUi from "@fastify/swagger-ui";
import { setupWebsocket } from "./sockets/websocket";

//add websocket

const server: FastifyInstance = fastify({
  logger:
    process.env.NODE_ENV === "development"
      ? {
          transport: {
            target: "pino-pretty",
          },
        }
      : true,
});

// add error handling
process.on("unhandledRejection", (err) => {
  console.error("unhandled rejection:", err);
  process.exit(1);
});

// health check route
server.get("/health", async () => {
  return { status: "ok", message: "server is running" };
});

// register routes
server.register(swagger, {
  openapi: {
    info: {
      title: "Facelook API Documentation",
      description: "API documentation for Facelook backend services",
      version: "1.0.0",
    },
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "apiKey",
          name: "Authorization",
          in: "header",
        },
      },
    },
  },
});

server.register(swaggerUi, {
  routePrefix: "/documentation",
  uiConfig: {
    docExpansion: "list",
    deepLinking: false,
  },
});

// register routes
server.register(require("@fastify/cors"), {
  origin: true, // allow all origins
});
// register plugins
server.register(require("@fastify/formbody"));

server.register(authRoutes, { prefix: "/api" });
server.register(friendRoutes, { prefix: "/api" });
server.register(groupRoutes, { prefix: "/api" });
server.register(invitationRoutes, { prefix: "/api" });
server.register(chatRoutes, { prefix: "/api" });

const verifyToken = async (request: FastifyRequest) => {
  try {
    const token = request.headers.authorization?.replace("Bearer ", "");

    if (!token) {
      throw new Error("no JWT token provided");
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as JWTPayload;

    // check if the token is expired
    if (Date.now() >= decoded.exp * 1000) {
      throw new Error("JWT token expired");
    }

    return decoded;
  } catch (error) {
    throw new Error("invalid JWT token");
  }
};

// add verifyToken hook, but exclude some paths
server.addHook("preHandler", async (request) => {
  const excludedPaths = [
    "/health",
    "/api/auth/login",
    "/api/auth/register",
    "/documentation",
    "/documentation/json",
    "/documentation/yaml",
    "/documentation/static/*",
  ];
  if (
    excludedPaths.includes(request.url) ||
    request.url.startsWith("/documentation/")
  ) {
    return;
  }

  await verifyToken(request);
});

// Define the WebSocket route e.g.) "ws://localhost:3001/ws?groupId=12345"
setupWebsocket(server);

const start = async () => {
  try {
    const address = await server.listen({
      port: 3001,
      host: "0.0.0.0",
    });
    console.log(`server started at: ${address}`);
  } catch (err) {
    console.error("server start failed:", err);
    process.exit(1);
  }
};

start();
