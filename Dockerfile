

FROM elixir as build_image
WORKDIR /app
RUN  mix local.hex --force && mix local.rebar --force
COPY mix.exs mix.lock ./
RUN mix deps.get && mix deps.compile
COPY . .
RUN mix release


FROM elixir
WORKDIR /app
COPY --from=build_image /app/_build/prod/rel/web_server/bin /app/

ENV MIX_ENV=prod
EXPOSE 8081


CMD /app/web_server start

# docker create -p 8080:80 --name webserver helloworld:latest