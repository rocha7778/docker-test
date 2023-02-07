

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

# docker build -t http_connector:v1.0 .
# docker create -p 8083:8082 --name webserverv  http_connector:v1.0
# docker start webserverv
# _build/prod/rel/web_server/bin/web_server start



# docker build -t web_ocp:v1 .

# crear tag para subir :  docker  tag http_connector:v1.0   rocha7778/ocp_web:v.2
# subir imagen: docker push rocha7778/ocp_web:v.2
# docker create -p 8083:8082 --name webserverv2  web_ocp:v1
# subir imagen a ocp:  oc import-image rocha7778/ocp_web:v.2 --confirm

# oc port-forward redis-db8cb58f7-crrh5 6379:6379
#
# docker start webserver
# _build/prod/rel/web_server/bin/web_server start


# docker create -p 8083:8082 --name webserverv2  test_copy

