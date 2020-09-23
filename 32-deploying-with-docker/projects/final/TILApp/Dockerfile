#1
FROM swift:4.2
#2
WORKDIR /app
#3
COPY . .
#4
RUN swift package clean
RUN swift build -c release
RUN mkdir /app/bin
RUN mv `swift build -c release --show-bin-path` /app/bin
EXPOSE 8080
#5
ENTRYPOINT ./bin/release/Run serve --env local --hostname 0.0.0.0
