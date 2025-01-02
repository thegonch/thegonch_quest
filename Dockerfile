FROM node:10

WORKDIR '/app'

COPY package.json .

COPY . .

RUN npm install express

EXPOSE 3000

# ENV SECRET_WORD

CMD ["npm", "start"]