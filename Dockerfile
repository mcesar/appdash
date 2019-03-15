# syntax=docker/dockerfile:experimental
FROM golang:1.11-alpine as stage1

WORKDIR /app

RUN apk add --no-cache git gcc libc-dev 

COPY go.mod .
COPY go.sum .
RUN --mount=type=ssh go mod download

COPY . .


RUN --mount=type=cache,target=/root/.cache/go-build \
    cd cmd/appdash \
    && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -installsuffix cgo -ldflags="-w -s" -o /app/app

FROM scratch

COPY --from=stage1 /app/app /

COPY --from=stage1 /tmp /tmp

CMD [ "/app", "serve", "--url=/" ]