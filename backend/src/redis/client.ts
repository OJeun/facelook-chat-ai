// src/redis/client.ts
import { createClient } from "redis";

export const redisClient = createClient({ url: process.env.REDIS_URL });

export async function initializeRedis() {
  console.log(process.env.REDIS_URL);
  try {
    await redisClient.connect();
    console.log("Redis connected successfully");
  } catch (error) {
    console.error("Redis connection failed:", error);
    process.exit(1);
  }
}
