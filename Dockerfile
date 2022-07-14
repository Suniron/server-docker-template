# ================
# == BASE STAGE ==
# ================
FROM node:16-alpine as base

WORKDIR /app

COPY package*.json .

# ==========================================
# == DEVELOPMENT STAGE (local usage only) ==
# ==========================================
FROM base as development

ENV NODE_ENV=development

CMD [ "npm", "run", "dev" ]

# == BUILDER ==
FROM base as builder

# This is needed to have all build dependencies:
ENV NODE_ENV=development

RUN npm ci 

COPY tsconfig*.json ./

# Only src subfolders & files are needed to build 
COPY ./src /app/src

RUN npm run build

# ======================
# == PRODUCTION STAGE ==
# ======================
FROM base as production

ENV NODE_ENV=production

# Do a clean install of packages (with only production dependencies mode because "NODE_ENV=production")
RUN npm ci

# To have lightest as possible, take only built files:
COPY --from=builder --chown=node:node /app/dist/ /app/dist

# Switch to "node" user to improve security
USER node

CMD [ "npm", "run", "start" ]
