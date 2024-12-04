import { FastifyInstance } from "fastify";
import fastifyWebsocket from "@fastify/websocket";
// import { redisClient } from "../redis/client";
import {
  saveMessage,
  getRecentMessages,
  clearMessages,
} from "../redis/message";
import { WebSocket } from "ws";
import { dumpMessagesToDB } from "../redis/dumpService";


const connectedClients: Record<string, Set<WebSocket>> = {};
const dumpTimers: Record<string, NodeJS.Timeout> = {};

export function setupWebsocket(server: FastifyInstance) {
  server.register(fastifyWebsocket, {
    options: {
      maxPayload: 1048576, // 1MB
    },
  }); //register websocket

  server.get("/ws", { websocket: true }, async (connection, req) => {
    console.log("req: ", req.body);
    const url = connection.url;

    if (!url) {
      console.error("No URL found in connection");
      connection.close();
      return;
    }

    const querystring = url.split("?")[1];
    const groupId = querystring?.split("=")[1];

    if (!groupId) {
      console.error("No group id found in URL");
      connection.close();
      return;
    }


    if (!connectedClients[groupId]) {
      connectedClients[groupId] = new Set();

      dumpTimers[groupId] = setInterval(() => {
        dumpMessagesToDB(groupId);
      }, 10 * 60 * 1000);
    }

    connectedClients[groupId].add(connection);

    // Server -> Client, send recent messges to one who just connected
    const recentMessages = await getRecentMessages(groupId);
    console.log("connection function: ", connection.send);
    console.log("recentMessages: ", recentMessages);
  
    connection.send(
      JSON.stringify({ type: "recentMessages", messages: recentMessages })
    );

    // Client -> Server
    connection.on("message", async (messageBuffer) => {
      const message = JSON.parse(messageBuffer.toString());
      await saveMessage(message);

      // broadcast message to all connected clients
      for (const client of connectedClients[groupId]) {
        if (client.readyState == WebSocket.OPEN) {
          client.send(JSON.stringify({ type: "newMessage", message }));
        }
      }
    });

    connection.on("close", async () => {
      connectedClients[groupId].delete(connection);

      if (connectedClients[groupId].size === 0) {
        clearInterval(dumpTimers[groupId]);
        delete dumpTimers[groupId];
        await dumpMessagesToDB(groupId);
        await clearMessages(groupId);
      }
    });
  });
}
