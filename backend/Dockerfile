FROM node:20.18.0-alpine

WORKDIR /app

COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .
RUN yarn build

# 只需要暴露一个端口
EXPOSE 3001

CMD ["yarn", "start"]