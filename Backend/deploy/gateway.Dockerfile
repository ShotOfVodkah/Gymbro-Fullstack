FROM golang:1.25 as build

WORKDIR /app

COPY services/gateway/go.mod ./ 
RUN go mod download

COPY services/gateway ./services/gateway

RUN cd services/gateway && go build -o /bin/gateway ./cmd/gateway

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=build /bin/gateway /usr/local/bin/gateway

EXPOSE 8080
ENTRYPOINT ["gateway"]