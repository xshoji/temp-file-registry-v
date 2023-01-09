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
$ md5 /tmp/webapp.tar.gz
MD5 (/tmp/webapp.tar.gz) = a9d8d8b3427e94fa883b41d50706d4df
$ curl -vvv -L -X POST "http://localhost:8080/temp-file-registry-v/api/v1/upload" -F "key=kioveyzrrt" -F "file=@/tmp/webapp.tar.gz" -F "expiration-minutes=3"
...
{"form":{"key":"kioveyzrrt287opddhk9"},"file_name":"webapp.tar.gz","file_content_type":"application/octet-stream"}
```

## Download

```
# delete: if "true" specified, target file will be deleted after response.
$ curl -vvv -L -X GET "http://localhost:8080/temp-file-registry-v/api/v1/download?key=kioveyzrrt&delete=true" -o /tmp/webapp2.tar.gz
$ md5 /tmp/webapp2.tar.gz
MD5 (/tmp/webapp2.tar.gz) = a9d8d8b3427e94fa883b41d50706d4df
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

