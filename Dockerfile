FROM joseluisq/static-web-server:2.44.1@sha256:94618e3d17802265a21926217e6f9e7832b311b6fbf5933684001739fafed06a AS static-web-server
FROM node:lts-alpine3.23@sha256:e44c87c7dd212720eb00469aeac89504ca2be77b8f0d6dbffb30665d5fcc59e1

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
