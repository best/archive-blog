FROM ihacker/hexo:latest as builder
WORKDIR /root/blog
COPY . .
RUN npm install && hexo generate

FROM nginx:alpine
COPY --from=builder /root/blog/public /usr/share/nginx/html