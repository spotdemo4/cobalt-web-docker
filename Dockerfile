FROM joseluisq/static-web-server:2.44.1@sha256:94618e3d17802265a21926217e6f9e7832b311b6fbf5933684001739fafed06a AS static-web-server
FROM node:lts-alpine3.23@sha256:44a3247313f9bc069a4ec25d01b66254ed7dc4d0408727d8720dc827f0753423

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
