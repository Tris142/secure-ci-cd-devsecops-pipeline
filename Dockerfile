FROM alpine as builder
COPY Makefile ./src /
RUN make build

FROM alpine as runtime
RUN addgroup -S nonroot \
    && adduser -S nonroot -G nonroot
COPY --from=builder bin/production /app
USER nonroot
ENTRYPOINT ["/app/production"]
