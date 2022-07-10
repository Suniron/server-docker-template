# == BASE ==
FROM node:16.16-alpine3.16 as base

WORKDIR /app

COPY --chown=node:node package*.json .

# == DEVELOPMENT (local) ==
FROM base as development

ENV NODE_ENV=development

RUN npm install

COPY --chown=node:node . .

USER node 

CMD [ "npm", "run", "dev" ]

# == BUILDER ==
FROM base as builder

RUN npm ci 

COPY --chown=node:node tsconfig*.json ./

COPY --chown=node:node src src

RUN npm run build

# == PRODUCTION ==
FROM builder as prod

ENV NODE_ENV=production

# Do a clean install of packages
RUN npm ci --only=production

USER node 

CMD [ "npm", "run", "start" ]
