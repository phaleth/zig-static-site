FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS site-builder

ENV DOCFX_VERSION=2.76.0

WORKDIR /app

RUN apt update; \
  apt install -y --no-install-recommends lsb-release apt-transport-https \
  build-essential wget unzip; \
  wget -c https://github.com/dotnet/docfx/releases/download/v${DOCFX_VERSION}/docfx-linux-x64-v${DOCFX_VERSION}.zip -O docfx.zip; \
  unzip docfx.zip; \
  ./docfx init -y; \
  ./docfx build docfx.json; \
  wget -c https://raw.githubusercontent.com/sujalgoel/404-html/master/index.html -O _site/404.html

FROM alpine AS app-builder

ENV ZIG_VERSION=0.13.0

WORKDIR /app

RUN mkdir zig; cd zig; \
  wget -c https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz -O zig.tar.xz; \
  tar xf zig.tar.xz; \
  rm zig.tar.xz; cd ..; \
  mkdir website; cd website; \
  ../zig/zig-linux-x86_64-${ZIG_VERSION}/zig init; \
  ../zig/zig-linux-x86_64-${ZIG_VERSION}/zig fetch --save git+https://github.com/andrewrk/StaticHttpFileServer/#HEAD; \
  rm src/*.zig; \
  wget -c https://raw.githubusercontent.com/andrewrk/StaticHttpFileServer/main/serve.zig -O src/main.zig; \
  sed -i s'/127\.0\.0\.1/0.0.0.0/g' src/main.zig

COPY build.zig ./website

RUN cd website; \
  ../zig/zig-linux-x86_64-${ZIG_VERSION}/zig build

FROM alpine

COPY --from=site-builder /app/_site ./wwwroot
COPY --from=app-builder /app/website/zig-out/bin/webserver .

CMD ["./webserver", "./wwwroot", "-p", "8080"]
