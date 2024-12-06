import { getRecentMessagesFromRedis } from "./message";
import { saveMessagesToDB } from "../services/databaseService";

export async function dumpMessagesToDB(groupId: string) {
  console.log(`2. Dumping messages for group ${groupId}, time: ${new Date().toISOString()}`);

  const messages = await getRecentMessagesFromRedis(groupId);
  if (messages.length === 0) return;

  try {
    console.log(`!!!!! saveMessagesToDB: ${messages[0].message}`);
    await saveMessagesToDB(groupId, messages); 
    console.log(`3. Messages for group ${groupId} successfully dumped.`);
  } catch (error) {
    console.error(`7. Failed to dump messages for group ${groupId}:`, error);
  }
}
