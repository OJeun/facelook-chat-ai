import { FastifyInstance } from "fastify";
import WebSocket, { WebSocketServer } from "ws";
import {
  saveMessage,
  getRecentMessages,
  clearMessages,
} from "../redis/message";
import { dumpMessagesToDB } from "../redis/dumpService";

const connectedClients: Record<string, Set<WebSocket>> = {};

export function setupWebsocket(server: FastifyInstance) {
  // Create a WebSocket server and attach it to the Fastify server
  const wss = new WebSocketServer({ noServer: true });

  // Handle WebSocket upgrade requests
  server.server.on("upgrade", (request, socket, head) => {
    if (request.url?.startsWith("/ws")) {
      wss.handleUpgrade(request, socket, head, (ws) => {
        wss.emit("connection", ws, request);
      });
    } else {
      socket.destroy();
    }
  });

  // Handle WebSocket connections
  wss.on("connection", async (socket, request) => {
    const url = request.url;

    if (!url) {
      console.error("No URL found in request");
      socket.close();
      return;
    }

    const querystring = url.split("?")[1];
    const groupId = querystring?.split("=")[1];

    if (!groupId) {
      console.error("No group ID found in URL");
      socket.close();
      return;
    }

    if (!connectedClients[groupId]) {
      connectedClients[groupId] = new Set();
    }

    setInterval(() => {
      for (const socket of connectedClients[groupId]) {
        if (socket.readyState !== WebSocket.OPEN) {
          connectedClients[groupId].delete(socket);
        }
      }
    }, 10000);

    connectedClients[groupId].add(socket);
    console.log(
      `Connected clients for group ${groupId}:`,
      connectedClients[groupId].size
    );

    const recentMessages = await getRecentMessages(groupId);
    console.log(`!!!Sending ${recentMessages} recent messages to client`);
    socket.send(
      JSON.stringify({ type: "recentMessages", messages: recentMessages })
    );

    socket.on("message", async (messageBuffer) => {
      const message = JSON.parse(messageBuffer.toString());
      console.log(`Received message: ${message}`);

      await saveMessage(message);

      for (const client of connectedClients[groupId]) {
        if (client.readyState === WebSocket.OPEN) {
          client.send(JSON.stringify({ type: "newMessage", messages: [message] }));
        }
      }
    });

    socket.on("close", async () => {

      connectedClients[groupId].delete(socket);

      if (connectedClients[groupId].size === 0) {
        console.log(`All users have left group ${groupId}. Cleaning up...`);

        try {
          await dumpMessagesToDB(groupId);
          console.log(`. Messages for group ${groupId} successfully saved.`);
        } catch (error) {
          console.error(
            error
          );
        }

        try {
          await clearMessages(groupId); // Remove messages from Redis
        } catch (error) {
          console.error(
            error
          );
        }
      } else {
        console.log(
        );
      }
    });
  });
}
