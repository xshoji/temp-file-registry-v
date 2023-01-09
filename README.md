# temp-file-registry-v

temp-file-registry-v is temporal file registry written by [vlang](https://github.com/vlang/v).

In case of Linux, needs install "musl-dev".

```
# ubuntu
apt-get install musl-dev
```

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

# API

## Upload

```
$ md5 /tmp/app
MD5 (/tmp/app) = ab4f8fce1ff101a6579af0a2bfd02f2f
$ curl -vvv -L -X POST "http://localhost:8080/temp-file-registry-v/api/v1/upload" -F "key=kioveyzrrt" -F "file=@/tmp/app" -F "expiration-minutes=3"
...
{"message":"key:kioveyzrrt, expired_at:2023-01-09 22:25:20.945, http_file.content_type:application/octet-stream, http_file.filename:app, http_file.data.bytes:2146824"}
```

## Download

```
# delete: if "true" specified, target file will be deleted after response.
$ curl -vvv -L -X GET "http://localhost:8080/temp-file-registry-v/api/v1/download?key=kioveyzrrt&delete=true" -o /tmp/app2
$ $ md5 /tmp/app2
MD5 (/tmp/app2) = ab4f8fce1ff101a6579af0a2bfd02f2f
```

# Release

```
# Release for linux
git tag v0.0.1-linux -m "Release beta version." && git push --tags

# Release for macOS and windows
git tag v0.0.1-macos-windows -m "Release beta version." && git push --tags



# Delete tag
echo "v0.0.1-linux" |xargs -I{} bash -c "git tag -d {} && git push origin :{}"

# Delete tag and recreate new tag and push
echo "v0.0.2-linux" |xargs -I{} bash -c "git tag -d {} && git push origin :{}; git tag {} -m \"Release beta version.\"; git push --tags"
```


# References

> global-variables - v/docs.md at master · vlang/v  
> https://github.com/vlang/v/blob/master/doc/docs.md#global-variables  

