# Using the most recent version of node to build the express server
FROM node:23
WORKDIR /app
COPY . .
RUN npm install
EXPOSE 3000
ENV SECRET_WORD=$SECRET_WORD
CMD ["npm", "start"]