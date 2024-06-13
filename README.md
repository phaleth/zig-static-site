# Zig Static Site

An attempt to deploy a docfx boilerplate using zig.

## Build and Run deployment using Docker locally

### Clean
```sh
docker stop zig-static-site
docker rmi zig-static-site:$(date '+%Y-%m-%d')
```

### Build
```sh
docker build -t zig-static-site:$(date '+%Y-%m-%d') .
docker builder prune
```

### Run
```sh
docker run --rm -d -p 8080:8080 --name=zig-static-site zig-static-site:$(date '+%Y-%m-%d')
docker logs zig-static-site -f
```

### Verify
```sh
docker exec -it zig-static-site sh
ls -lha ./wwwroot
exit
```
