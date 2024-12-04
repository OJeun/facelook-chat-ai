import { FastifyInstance } from "fastify";
import WebSocket, { WebSocketServer } from "ws";
import {
  saveMessage,
  getRecentMessages,
  clearMessages,
} from "../redis/message";
import { dumpMessagesToDB } from "../redis/dumpService";

const connectedClients: Record<string, Set<WebSocket>> = {};
const dumpTimers: Record<string, NodeJS.Timeout> = {};

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

      dumpTimers[groupId] = setInterval(() => {
        dumpMessagesToDB(groupId);
      }, 10 * 60 * 1000);
    }

    connectedClients[groupId].add(socket);

    const recentMessages = await getRecentMessages(groupId);
    socket.send(JSON.stringify({ type: "recentMessages", messages: recentMessages }));

    socket.on("message", async (messageBuffer) => {
      const message = JSON.parse(messageBuffer.toString());
      await saveMessage(message);

      // Broadcast message to all connected clients in the same group
      for (const client of connectedClients[groupId]) {
        if (client.readyState === WebSocket.OPEN) {
          client.send(JSON.stringify({ type: "newMessage", message }));
        }
      }
    });

    // Handle WebSocket closure
    socket.on("close", async () => {
      connectedClients[groupId].delete(socket);

      if (connectedClients[groupId].size === 0) {
        clearInterval(dumpTimers[groupId]);
        delete dumpTimers[groupId];
        await dumpMessagesToDB(groupId);
        await clearMessages(groupId);
      }
    });
  });
}
