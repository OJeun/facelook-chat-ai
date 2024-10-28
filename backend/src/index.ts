// src/index.ts
import fastify from 'fastify';

const app = fastify();

app.get('/', async () => {
  return { hello: 'world' };
});

const start = async () => {
  try {
    await app.listen({ port: 3000 });
    console.log('Server is running on http://localhost:3000');
  } catch (err) {
    app.log.error(err);
    app.close();
  }
};

start();
