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

$ http localhost:3000 link=https://passy.me/ tags:='["hello", "passy"]'
HTTP/1.1 200 OK

$ http localhost:3000

HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Date: Sat, 21 Mar 2015 16:26:40 GMT
Server: Warp/3.0.9.3
Transfer-Encoding: chunked

[
    {
        "date": "2015-03-21T16:25:41.874Z",
        "link": {
            "tags": [
                "hello",
                "passy"
            ],
            "uri": "https://passy.me/"
        }
    },
    {
        "date": "2015-03-21T16:25:23.628Z",
        "link": {
            "tags": [
                "hello",
                "world"
            ],
            "uri": "https://google.com/"
        }
    },
    {
        "date": "2015-03-21T16:25:41.874Z",
        "link": {
            "tags": [
                "hello",
                "passy"
            ],
            "uri": "https://passy.me/"
        }
    },
    {
        "date": "2015-03-21T16:25:23.628Z",
        "link": {
            "tags": [
                "hello",
                "world"
            ],
            "uri": "https://google.com/"
        }
    }
]


$ http localhost:3000/tags/passy
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
Date: Sat, 21 Mar 2015 16:27:38 GMT
Server: Warp/3.0.9.3
Transfer-Encoding: chunked

[
    {
        "date": "2015-03-21T16:25:41.874Z",
        "link": {
            "tags": [
                "hello",
                "passy"
            ],
            "uri": "https://passy.me/"
        }
    }
]

```
