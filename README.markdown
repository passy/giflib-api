# giflib-api [![Build Status](https://travis-ci.org/passy/giflib-api.svg)](https://travis-ci.org/passy/giflib-api)

My attempt to build a web/json API with Scotty and some database later on.

## Running

I like [halcyon](https://halcyon.sh/).

```bash
$ ln -sf /app/sandbox/cabal.sandbox.config .
$ halcyon build
$ cabal run
$ open http://localhost:3000/
```

## Using

Get [httpie](http://httpie.org), because CURL is for masochists.

```bash
$ cabal run
$ http localhost:3000 link=https://google.com/ tags:='["hello", "world"]'
HTTP/1.1 200 OK

$ http localhost:3000
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Date: Sun, 01 Mar 2015 20:19:16 GMT
Server: Warp/3.0.9.2
Transfer-Encoding: chunked

[
    {
        "link": "https://google.com/",
        "tags": [
            "hello",
            "world"
        ]
    }
]

$ http localhost:3000/tags/hello
...
```
