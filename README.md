# 🧠 FACELook Chat AI – Backend

💬 What is FaceLook? <br>
FaceLook is a real-time group chat application where users can see each other's emotions through expressive emoji reactions — intelligently generated by AI analyzing the conversation. It enhances social interaction by visualizing feelings in a fun, intuitive way.

⚙️ How it Works? <br>
Under the hood, FaceLook runs on a fast and scalable backend powered by Fastify, WebSocket, Redis, and TypeScript.
It supports real-time messaging, AI-powered sentiment analysis via OpenAI, and efficient message buffering through Redis to ensure high performance and reliability.


---

## 🚀 Features

- ⚡ Real-time WebSocket communication per group
- 🔁 Redis buffering layer for temporary chat storage
- 🧠 OpenAI-powered responses for AI-based interactions
- 🧹 Automatic cleanup and DB dump when all users leave a room
- 🔐 JWT-based authentication-ready
- 🐳 Fully containerized with Docker
---
## 📦 Dockerized Architecture

This backend uses **Docker** and **docker-compose** to manage:

- 🧠 Fastify WebSocket Server
- ⚡ Redis (temporary message storage)
- 🗄️ External database (for persistent chat logs)

### Why Docker?

Using Docker gives us:

- ✅ Consistent environments across dev & production
- 🚀 Easy deployment with `docker-compose up`
- 🧪 Isolated services (backend, RedIs)
- ☁️ Cloud-ready container support (Render, AWS, etc)

---

## 🧱 Architecture Overview

```mermaid
graph TD
  Client["Client (Browser)"]
  Server["Fastify Server (WebSocket + API)"]
  Redis["Redis (In-memory Cache)"]
  DB["Database (Persistent Storage)"]
  OpenAI["OpenAI API"]

  Client -->|WebSocket| Server
  Server -->|Save Message| Redis
  Server -->|Get Response| OpenAI
  Redis -->|Dump When Group Ends| DB
```
