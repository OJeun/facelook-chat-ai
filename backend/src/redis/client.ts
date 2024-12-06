// src/redis/client.ts
import { createClient } from "redis";

export const redisClient = createClient({ url: process.env.REDIS_URL });

let initialCleanupDone = false;

export async function clearAllRedisData() {
  try {
    await redisClient.flushAll();
    console.log("Successfully cleared all Redis data");
  } catch (error) {
    console.error("Failed to clear Redis data:", error);
    throw error;
  }
}

export async function initializeRedis() {
  try {
    await redisClient.connect();
    console.log("Redis connected successfully");

    if (!initialCleanupDone) {
      setTimeout(async () => {
        await clearAllRedisData();
        initialCleanupDone = true;
      }, 1000);
    }
  } catch (error) {
    console.error("Redis connection failed:", error);
    process.exit(1);
  }
}
