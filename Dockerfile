FROM node:22-slim
WORKDIR /app
COPY package*.json ./
RUN npm install --omit=dev
COPY . .
ENV NODE_ENV=production
EXPOSE 3000
VOLUME ["/app/data"]
ENV DB_FILE=/app/data/dayline.db
CMD ["node", "server.js"]
