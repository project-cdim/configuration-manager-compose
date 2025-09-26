FROM golang:1.24-alpine3.22

# upgrading packages
RUN apk update && \
    apk upgrade --available && \
    apk add --no-cache \
    curl

WORKDIR /app/logger
COPY ./configuration-manager/configuration-manager/logger/go.mod ./
COPY ./configuration-manager/configuration-manager/logger/go.sum ./
RUN go mod download

WORKDIR /app
COPY ./configuration-manager/configuration-manager/go.mod ./
COPY ./configuration-manager/configuration-manager/go.sum ./
RUN go mod download

# go build and exec
COPY configuration-manager/configuration-manager .
RUN go build -o /configuration-manager
CMD [ "/configuration-manager" ]
