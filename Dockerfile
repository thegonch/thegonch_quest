FROM node:latest

WORKDIR '/app'

COPY package.json .

COPY . .

RUN npm install express

EXPOSE 3000

ARG SECRET_WORD

ENV SECRET_WORD $SECRET_WORD

CMD ["npm", "start"]