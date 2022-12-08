

FROM elixir as build_image
WORKDIR /app
RUN  mix local.hex --force && mix local.rebar --force
COPY mix.exs mix.lock ./
RUN mix deps.get && mix deps.compile
COPY . .
RUN mix release
ENV MIX_ENV=prod
EXPOSE 8081


CMD _build/prod/rel/web_server/bin/web_server start