import { FastifyInstance } from "fastify";
import WebSocket, { WebSocketServer } from "ws";
import {
  saveMessage,
  getRecentMessages,
  clearMessages,
} from "../redis/message";
import { dumpMessagesToDB } from "../redis/dumpService";

const connectedClients: Record<string, Set<WebSocket>> = {};
const clientConnections: Record<string, WebSocket> = {}; // 클라이언트별 연결 관리
const dumpTimers: Record<string, NodeJS.Timeout> = {};

export function setupWebsocket(server: FastifyInstance) {
  const wss = new WebSocketServer({ noServer: true });

  server.server.on("upgrade", (request, socket, head) => {
    if (request.url?.startsWith("/ws")) {
      wss.handleUpgrade(request, socket, head, (ws) => {
        wss.emit("connection", ws, request);
      });
    } else {
      socket.destroy();
    }
  });

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

    // 중복 연결 방지: 클라이언트가 이미 연결된 경우 기존 연결 사용
    const clientKey = `${groupId}-${request.socket.remoteAddress}`;
    if (clientConnections[clientKey]) {
      console.log(`Client already connected to group ${groupId}`);
      socket.close();
      return;
    }

    clientConnections[clientKey] = socket;

    if (!connectedClients[groupId]) {
      connectedClients[groupId] = new Set();

      dumpTimers[groupId] = setInterval(() => {
        dumpMessagesToDB(groupId);
      }, 10 * 60 * 1000);
    }

    connectedClients[groupId].add(socket);

    console.log(`Connected clients for group ${groupId}:`, connectedClients[groupId].size);

    const recentMessages = await getRecentMessages(groupId);
    socket.send(JSON.stringify({ type: "recentMessages", messages: recentMessages }));

    socket.on("message", async (messageBuffer) => {
      const message = JSON.parse(messageBuffer.toString());
      console.log(`Received message: ${message}`);

      await saveMessage(message);

      for (const client of connectedClients[groupId]) {
        if (client.readyState === WebSocket.OPEN) {
          client.send(JSON.stringify({ type: "newMessage", message }));
        }
      }
    });

    socket.on("close", async () => {
      connectedClients[groupId].delete(socket);
      delete clientConnections[clientKey]; // 연결 제거

      if (connectedClients[groupId].size === 0) {
        console.log(`All users have left group ${groupId}. Cleaning up...`);
        clearInterval(dumpTimers[groupId]);
        delete dumpTimers[groupId];

        try {
          await dumpMessagesToDB(groupId);
          await clearMessages(groupId);
        } catch (error) {
          console.error(`Error during cleanup for group ${groupId}:`, error);
        }
      } else {
        console.log(
          `User disconnected from group ${groupId}. Remaining users: ${connectedClients[groupId].size}`
        );
      }
    });
  });
}
