# docker manifest inspect golang:alpine 
{
   "schemaVersion": 2,
   "mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
   "manifests": [
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 1365,
         "digest": "sha256:70df3b8f9f099da7f60f0b32480015165e3d0b51bfacf9e255b59f3dd6bd2828",
         "platform": {
            "architecture": "amd64",
            "os": "linux"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 1365,
         "digest": "sha256:f6867b4fcbcbefaed0422da6945039d11286ceaa389765018d3997acd977cc67",
         "platform": {
            "architecture": "arm",
            "os": "linux",
            "variant": "v6"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 1365,
         "digest": "sha256:003cb5a71695412f555f4ac2f61ae2451c013d31802bbb172efa7bcd41c57d0b",
         "platform": {
            "architecture": "arm",
            "os": "linux",
            "variant": "v7"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 1365,
         "digest": "sha256:24bd9ec1f81942951499f9ebe5d7c95ea42355a0c65a8593a0f73d93a26da223",
         "platform": {
            "architecture": "arm64",
            "os": "linux",
            "variant": "v8"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 1365,
         "digest": "sha256:c771cbf29bb32761c34b48bc407bd82cc7ade5050470b49a372587d266cfc9ca",
         "platform": {
            "architecture": "386",
            "os": "linux"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 1365,
         "digest": "sha256:9a46e7e73b9225c57173eff97cfe1d2fafaa09719ca95fb0fa160347342b3432",
         "platform": {
            "architecture": "ppc64le",
            "os": "linux"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 1365,
         "digest": "sha256:b1bfa3c4eed6a5870f825a6b29ad07e10e236d74c8a2f364e9f304f26c97aa7f",
         "platform": {
            "architecture": "s390x",
            "os": "linux"
         }
      }
   ]
}

docker pull golang@sha256:24bd9ec1f81942951499f9ebe5d7c95ea42355a0c65a8593a0f73d93a26da223

docker tag golang@sha256:24bd9ec1f81942951499f9ebe5d7c95ea42355a0c65a8593a0f73d93a26da223 harbor:443/library/golang:alpine-arm64

docker push harbor:443/library/golang:alpine-arm64

docker pull golang@sha256:70df3b8f9f099da7f60f0b32480015165e3d0b51bfacf9e255b59f3dd6bd2828

docker tag golang@sha256:70df3b8f9f099da7f60f0b32480015165e3d0b51bfacf9e255b59f3dd6bd2828 harbor:443/library/golang:alpine-amd64

docker push harbor:443/library/golang:alpine-amd64

docker manifest create harbor:443/library/golang:alpine harbor:443/library/golang:alpine-amd64 harbor:443/library/golang:alpine-arm64

docker manifest push harbor:443/library/golang:alpine

# docker manifest inspect alpine:latest
{
   "schemaVersion": 2,
   "mediaType": "application/vnd.docker.distribution.manifest.list.v2+json",
   "manifests": [
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:1304f174557314a7ed9eddb4eab12fed12cb0cd9809e4c28f29af86979a3c870",
         "platform": {
            "architecture": "amd64",
            "os": "linux"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:5da989a9a3a08357bc7c00bd46c3ed782e1aeefc833e0049e6834ec1dcad8a42",
         "platform": {
            "architecture": "arm",
            "os": "linux",
            "variant": "v6"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:0c673ee68853a04014c0c623ba5ee21ee700e1d71f7ac1160ddb2e31c6fdbb18",
         "platform": {
            "architecture": "arm",
            "os": "linux",
            "variant": "v7"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:ed73e2bee79b3428995b16fce4221fc715a849152f364929cdccdc83db5f3d5c",
         "platform": {
            "architecture": "arm64",
            "os": "linux",
            "variant": "v8"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:1d96e60e5270815238e999aed0ae61d22ac6f5e5f976054b24796d0e0158b39c",
         "platform": {
            "architecture": "386",
            "os": "linux"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:fa30af02cc8c339dd7ffecb0703cd4a3db175e56875c413464c5ba46821253a8",
         "platform": {
            "architecture": "ppc64le",
            "os": "linux"
         }
      },
      {
         "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
         "size": 528,
         "digest": "sha256:c2046a6c3d2db4f75bfb8062607cc8ff47896f2d683b7f18fe6b6cf368af3c60",
         "platform": {
            "architecture": "s390x",
            "os": "linux"
         }
      }
   ]
}




docker pull alpine@sha256:ed73e2bee79b3428995b16fce4221fc715a849152f364929cdccdc83db5f3d5c

docker tag alpine@sha256:ed73e2bee79b3428995b16fce4221fc715a849152f364929cdccdc83db5f3d5c harbor:443/library/alpine:latest-arm64

docker push harbor:443/library/alpine:latest-arm64

docker pull alpine:latest

docker tag alpine:latest harbor:443/library/alpine:latest-amd64

docker push harbor:443/library/alpine:latest-amd64

docker manifest create harbor:443/library/alpine:latest harbor:443/library/alpine:latest-amd64 harbor:443/library/alpine:latest-arm64

docker manifest push harbor:443/library/alpine:latest


# cat /etc/docker/daemon.json
{
	"experimental": true,
	"registry-mirrors": ["https://harbor"]
}


# cat buildkitd.toml 
debug = true
[registry."harbor:443"]
  ca=["/etc/pki/ca-trust/source/anchors/ca.crt"]


# cat main.go 
package main

import (
        "fmt"
        "runtime"
)

func main() {
        fmt.Printf("Hello, %s!\n", runtime.GOARCH)
}


# cat Dockerfile.bak 
FROM harbor:443/library/golang:alpine AS builder
ENV GO111MODULE auto
RUN mkdir /app
ADD . /app/
WORKDIR /app
RUN go build -o hello .

FROM harbor:443/library/alpine:latest
RUN mkdir /app
WORKDIR /app
COPY --from=builder /app/hello .
CMD ["./hello"]



docker buildx build --push --platform linux/amd64,linux/arm64 -t harbor:443/library/hello:v2 --builder=container -f Dockerfile.bak .
