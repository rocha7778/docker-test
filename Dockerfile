

FROM elixir as build_image
ENV MIX_ENV=prod
WORKDIR /app
RUN  mix local.hex --force && mix local.rebar --force
COPY mix.exs mix.lock ./
RUN mix deps.get && mix deps.compile
COPY . .
RUN mix release


FROM elixir 
ENV MIX_ENV=prod
WORKDIR /app
EXPOSE 8081
COPY --from=build_image /app/_build/prod/  /app

CMD /app/rel/web_server/bin/web_server start

# docker build -t test_copy .
# docker create -p 8083:8082 --name webserverv2  web_eleixr
# docker start webserver
# _build/prod/rel/web_server/bin/web_server start
