import dotenv from "dotenv";
import { redisMessageWithTimeStamp } from "../models/chat";

dotenv.config();

export async function saveMessagesToDB(
  groupId: string,
  messages: redisMessageWithTimeStamp[]
) {
  console.log(
    `Saving ${messages.length} messages for group ${groupId} to MySQL.`
  );
  const db_api_url = process.env.DB_API_URL + "api/chat/saveChats";
  
  console.log("This is the messages that are being saved: ", messages[0].message);

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
    console.error("Failed to save messages to MySQL.");
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

  return (await response.json()) as redisMessageWithTimeStamp[];
}
