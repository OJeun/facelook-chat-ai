import dotenv from 'dotenv';
import { MessageWithTimestamp } from "../models/chat";

dotenv.config();

export async function saveMessage(groupId: string, messages: MessageWithTimestamp[]) {
    console.log(`Saving ${messages.length} messages for group ${groupId} to MySQL.`);
    const db_api_url = process.env.DB_API_URL + 'api/chat/saveChats';

    const response = await fetch(db_api_url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify({
            chatList: messages,
        }),
    });

    if (!response.ok) {
        console.error('Failed to save messages to MySQL.');
        return;
    }
  };

  export async function getMessagesFromDB(groupId: string, offset: number, limit: number): Promise<any[]> {
    console.log(`Retrieving messages for group ${groupId} from MySQL.`);
    const db_api_url = process.env.DB_API_URL + 'api/chat/getChats' + `?groupId=${groupId}&offset=${offset}&limit=${limit}`;

    const response = await fetch(db_api_url, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
        },
    });

    if (!response.ok) {
        console.error('Failed to retrieve messages from MySQL.');
        return [];
    }

    return await response.json() as any[];
    };



