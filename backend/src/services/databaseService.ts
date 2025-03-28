import dotenv from "dotenv";
import { redisMessageWithTimeStamp, messagesFromDB } from "../models/chat";
import axios from "axios";

dotenv.config();

export async function saveMessagesToDB(
  groupId: string,
  messages: redisMessageWithTimeStamp[]
) {
  console.log(
    `4. Saving ${messages.length} messages for group ${groupId} to MySQL.`
  );
  const db_api_url = process.env.DB_API_URL + "api/chat/saveChats";

  // Map messages to replace `id` with `chatId`
  const mappedMessages = messages.map((msg) => ({
    chatId: msg.id,
    groupId: parseInt(msg.groupId),
    senderId: msg.senderId,
    senderName: msg.senderName,
    message: msg.content,
    createdAt: msg.createdAt,
  }));


  const response = await fetch(db_api_url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      chatList: mappedMessages,
    }),
  });

  if (!response.ok) {
    console.error("6. Failed to save messages to MySQL.");
    return;
  }
}

export async function getMessagesFromDB(
  groupId: string,
  offset: number,
  limit: number
): Promise<messagesFromDB[]> {
  console.log(`Retrieving messages for group ${groupId} from MySQL.`);
  const db_api_url =
    `${process.env.DB_API_URL}api/chat/20Chats/${groupId}` +
    `?offset=${offset}&limit=${limit}`;

  console.log("This is the db_api_url: ", db_api_url);

  try {
    const response = await fetch(db_api_url, {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    });

    if (!response.ok) {
      console.error("Failed to retrieve messages from MySQL.");
      return [];
    }

    const jsonResponse = await response.json();

    if (jsonResponse && Array.isArray(jsonResponse.chats)) {
      return jsonResponse.chats.map((chat: messagesFromDB) => ({
        id: String(chat.chatId),
        groupId: String(chat.groupId), // Convert `groupId` to string
        senderId: chat.senderId,
        senderName: chat.senderName,
        content: chat.message, // Map `message` to `content`
        createdAt: chat.createdAt,
      }));
    } else {
      console.error(
        "Unexpected API response structure. Returning empty array."
      );
      return [];
    }
  } catch (error) {
    console.error("Error while fetching messages from MySQL:", error);
    return [];
  }
}

// add a db service to get data from select or insert query from db
export async function sendQueryToDB(query: string) {
  const db_api_url = process.env.DB_API_URL + "api/db/query";

  try {
    const response = await axios.post(db_api_url, {
      query: query,
    });

    if (response.status === 200) {
      return response.data;
    } else {
      console.error("Query failed:", response.statusText);
      return null;
    }
  } catch (error) {
    console.error("Error executing query:", error);
    return null;
  }
}
