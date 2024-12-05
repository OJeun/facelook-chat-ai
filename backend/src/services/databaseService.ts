import dotenv from "dotenv";
import { redisMessageWithTimeStamp } from "../models/chat";

dotenv.config();

export async function saveMessagesToDB(
  groupId: string,
  messages: redisMessageWithTimeStamp[]
) {
  console.log(
    `4. Saving ${messages.length} messages for group ${groupId} to MySQL.`
  );
  const db_api_url = process.env.DB_API_URL + "api/chat/saveChats";
  
  console.log("5. This is the messages that are being saved: ", messages);

  const response = await fetch(db_api_url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      chatList: messages,
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
): Promise<redisMessageWithTimeStamp[]> {
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
    console.log("Response from MySQL API:", jsonResponse);

    if (jsonResponse && Array.isArray(jsonResponse.chats)) {
      return jsonResponse.chats.map((chat: redisMessageWithTimeStamp) => ({
        ...chat,
        content: chat.message, 
        message: undefined,
      }));
    } else {
      console.error("Unexpected API response structure. Returning empty array.");
      return [];
    }
  } catch (error) {
    console.error("Error while fetching messages from MySQL:", error);
    return [];
  }
}
