FROM golang:alpine as backend_builder
WORKDIR /usr/src/backend
COPY /backend .
RUN go get
RUN go build

FROM debian:bullseye as frontend_builder
RUN apt update && apt install -y curl git unzip xz-utils zip
USER root
WORKDIR /home/root

RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git
WORKDIR /home/root
ENV PATH "$PATH:/home/root/flutter/bin"
RUN flutter precache --web
COPY /frontend ./frontend
WORKDIR /home/root/frontend
RUN flutter pub get
RUN flutter build web --web-renderer canvaskit

FROM alpine

WORKDIR /root
COPY --from=backend_builder /usr/src/backend/backend ./backend/
COPY --from=frontend_builder /home/root/frontend/build/web/ ./web_build

WORKDIR /root/backend
CMD ./backend -r -p $PORT -a 0.0.0.0 -c $DB_STRING -s $SECRET_KEY
