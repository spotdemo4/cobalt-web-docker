FROM joseluisq/static-web-server:2.41.0@sha256:34bb160fd62d2145dabd0598f36352653ec58cf80a8d58c8cd2617097d34564d AS static-web-server
FROM node:lts-alpine3.23@sha256:4f696fbf39f383c1e486030ba6b289a5d9af541642fc78ab197e584a113b9c03

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
