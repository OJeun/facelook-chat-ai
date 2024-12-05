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
  console.log(server)
  const wss = new WebSocketServer({ noServer: true });

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

  const clientKey = `${groupId}-${request.socket.remoteAddress}-${request.socket.remotePort}`;
  console.log(`Client key: ${clientKey}`);

  if (clientConnections[clientKey]) {
    console.log(`Closing existing connection for client: ${clientKey}`);
    clientConnections[clientKey].close();
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
    console.log(`Socket is closing for group ${groupId}:`, connectedClients[groupId].size);
    connectedClients[groupId].delete(socket);
    delete clientConnections[clientKey];

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
      console.log(`User disconnected from group ${groupId}. Remaining users: ${connectedClients[groupId].size}`);
    }
  });
});

}
