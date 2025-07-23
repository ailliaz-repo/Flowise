# Build local monorepo image
# docker build --no-cache -t  flowise .

# Run image
# docker run -d -p 3000:3000 flowise

FROM node:20-alpine
RUN apk add --update libc6-compat python3 make g++ \
    && apk add --no-cache build-base cairo-dev pango-dev \
    && apk add --no-cache chromium \
    && apk add --no-cache curl

# Install pnpm globally
RUN npm install -g pnpm

ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser
ENV NODE_OPTIONS=--max-old-space-size=8192

WORKDIR /usr/src

# Copy app source
COPY . .

# 👉 Install dependencies (inclusief pg)
RUN pnpm install && pnpm add pg

# 👉 Prisma hergenereren (soms nodig bij eigen build)
RUN pnpm exec prisma generate || true

RUN pnpm build

EXPOSE 3000

CMD [ "pnpm", "start" ]
