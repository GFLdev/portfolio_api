# Stage 1: Build
FROM golang:1.25 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
  -tags netgo \
  -o gfldev_portfolio_api \
  ./cmd/gfldev_portfolio_api

# Stage 2: Final
FROM gcr.io/distroless/base-debian12:nonroot

WORKDIR /app

COPY --from=builder /app/gfldev_portfolio_api /app/gfldev_portfolio_api

USER nonroot:nonroot

ENTRYPOINT ["/app/gfldev_portfolio_api"]
