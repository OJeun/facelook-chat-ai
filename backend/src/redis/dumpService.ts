import { getRecentMessages, clearMessages } from "./message";
import { saveMessagesToDB } from "../services/databaseService";
import { Mutex } from "async-mutex";

const groupLocks: Record<string, Mutex> = {};

export async function dumpMessagesToDB(groupId: string) {
    if (!groupLocks[groupId]) {
      groupLocks[groupId] = new Mutex();
    }
  
    const mutex = groupLocks[groupId];
    await mutex.runExclusive(async () => {
      const messages = await getRecentMessages(groupId);
      if (messages.length === 0) return;
  
      await saveMessagesToDB(groupId, messages);
      await clearMessages(groupId);
    });
  }