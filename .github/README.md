# [cobalt web](https://github.com/imputnet/cobalt/tree/main/web) docker images

[![version](https://ghcr-badge.egpl.dev/spotdemo4/cobalt-web/latest_tag?color=%2344cc11&ignore=latest&label=version&trim=)](https://github.com/spotdemo4/cobalt-web-docker/pkgs/container/cobalt-web)
[![size](https://ghcr-badge.egpl.dev/spotdemo4/cobalt-web/size?color=%2344cc11&tag=latest&label=image+size&trim=)](https://github.com/spotdemo4/cobalt-web-docker/pkgs/container/cobalt-web)

## docker-compose.yaml

```yaml
services:
  cobalt-web:
    image: ghcr.io/spotdemo4/cobalt-web:latest
    container_name: cobalt-web
    ports:
      - "8787:8787"
    environment:
      WEB_DEFAULT_API: https://api.cobalt.tools/ # url used for api requests; required
      WEB_HOST: cobalt.tools # domain on which the frontend will be running
      ENABLE_DEPRECATED_YOUTUBE_HLS: true # enables the youtube HLS settings entry
      WEB_PLAUSIBLE_HOST: plausible.io # plausible analytics with provided hostname
      PORT: 8787 # default 8787
      LOG_LEVEL: info # error, warn, info, debug, trace; default info
    restart: unless-stopped
```

More info on environment variables can be found [here](https://github.com/imputnet/cobalt/tree/main/web#environment-variables)
