FROM node:22-alpine

ENV NODE_ENV=production
WORKDIR /app

# sqlite3 ships prebuilt binaries for alpine; python/make are only needed if a rebuild is forced.
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev

COPY . .

# Railway mounts the persistent volume at /data (VOLUME instructions are not allowed by its builder).
ENV UPLOADS_DIR=/data/uploads
RUN mkdir -p /data/uploads

EXPOSE 3001
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1:${PORT:-3001}/health || exit 1

CMD ["node", "server.js"]
