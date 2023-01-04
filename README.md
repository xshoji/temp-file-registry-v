# temp-file-registry-v

Temporal file registry written by vlang.

```
# help
v run main.v -h
Usage:  [options] [ARGS]

Description:
  Temp file registry by vlang.
  Log level is specified as Environment variable e.g. export V_LOG_LEVEL=3
  (1:fatal, 2:error, 3:warn, 4:info, 5:debug) (default = 5:debug)


Options:
  -p, --port <int>          [optional] port (default: 8080)
  -h, --help                help
  -e, --expiration <int>    [optional] Default file expiration (minutes) (default: 10)
  -m, --max-file-size <int>
                            [optional] Max file size (MB) (default: 1024)

# execute
v run main.v

# build ( and cross-compilation )
v . -o /tmp/app
# v . -o /tmp/app -os macos
# v . -o /tmp/app -os linux
# v . -o /tmp/app.exe -os windows

# start
/tmp/app
```

## API

### Upload

```
curl --location --request POST 'http://localhost:8888/tempFileRegistry/api/v1/upload' \
--form 'key="kioveyzrrt287opddhk9"' \
--form 'file=@"/private/tmp/app"'
{"message":"key:kioveyzrrt287opddhk9, expiryTimeMinutes:10, fileHeader:map[Content-Disposition:[form-data; name="file"; filename="app"] Content-Type:[application/octet-stream]]"}
```

### Download

```
# delete: if "true" specified, target file will be deleted after response.
curl "http://localhost:8888/tempFileRegistry/api/v1/download?key=kioveyzrrt287opddhk9&delete=true" -o /tmp/app2
```
