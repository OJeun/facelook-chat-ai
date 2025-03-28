import { getRecentMessagesFromRedis } from "./message";
import { saveMessagesToDB } from "../services/databaseService";

export async function dumpMessagesToDB(groupId: string) {
  const messages = await getRecentMessagesFromRedis(groupId);
  if (messages.length === 0) return;

  try {
    await saveMessagesToDB(groupId, messages); 
  } catch (error) {
  }
}
