FROM node:12.7-alpine
# working directory
WORKDIR /usr/src/app
# install app dependencies
COPY package*.json ./
RUN npm install
# for production
# RUN npm ci --only=production
# bundle app source
COPY . .
# set application user
USER node
# run application
EXPOSE 8081
CMD [ "node", "server.js" ]