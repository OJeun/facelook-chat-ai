// src/index.ts
import fastify from "fastify";
// import { analyzeAllChats } from "./services/openai";

const app = fastify();

app.get("/", async () => {
  return { hello: "world" };
});

// test driver for openai services
// setTimeout(async () => {
//   const result = await analyzeAllChats();
//   console.log(result);
// }, 1000);

const start = async () => {
  try {
    await app.listen({ port: 3000 });
    console.log("Server is running on http://localhost:3000");
  } catch (err) {
    app.log.error(err);
    app.close();
  }
};

start();
