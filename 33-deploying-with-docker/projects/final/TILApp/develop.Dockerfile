FROM swift:5.3
WORKDIR /app
COPY . .
RUN swift package clean
RUN swift build -c release --enable-test-discovery
RUN mkdir /app/bin
RUN mv `swift build -c release --show-bin-path` /app/bin
EXPOSE 8080
ENTRYPOINT ./bin/release/Run serve --env local --hostname 0.0.0.0
