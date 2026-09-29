FROM node:20-alpine

WORKDIR /app

# Install only production dependencies (cached unless package files change)
COPY package*.json ./
RUN npm ci --omit=dev

COPY src ./src
COPY public ./public

# Values passed in by the pipeline
ARG APP_VERSION=dev
ARG GIT_COMMIT=local
ARG BUILD_TIME=unknown
ENV APP_VERSION=$APP_VERSION GIT_COMMIT=$GIT_COMMIT BUILD_TIME=$BUILD_TIME NODE_ENV=production PORT=3000

# Do not run as root
USER node

EXPOSE 3000
HEALTHCHECK --interval=15s --timeout=3s --retries=3 CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "src/server.js"]
