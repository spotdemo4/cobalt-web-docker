FROM joseluisq/static-web-server:2.44.2@sha256:23be6c04d474979d6e738081918f5874f88502a150d1123fd000719101a0f05c AS static-web-server
FROM node:lts-alpine3.23@sha256:39d8c143e60e99ae98f014bebea1e72fc96d3c9bdf9504bc3a27af5c05bfa39f

# deps
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
RUN apk add --no-cache git

# build deps
RUN git clone --depth 1 https://github.com/imputnet/cobalt.git cobalt
WORKDIR /cobalt
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile --filter=./web
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm --filter=./web exec svelte-kit sync

# runtime deps
COPY --from=static-web-server /static-web-server /usr/local/bin/static-web-server
COPY ./start.sh /start.sh

ENTRYPOINT ["/start.sh"]
