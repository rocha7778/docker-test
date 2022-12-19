

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
ENV REDIX_HOST=redis.capa-transaccional-lab.svc.cluster.local
ENV REDIX_PASSWORD=p@ss$12E45
ENV REDIX_PORT=6379
WORKDIR /app
EXPOSE 8082
COPY --from=build_image /app/_build/prod/  /app

CMD /app/rel/web_server/bin/web_server start

# docker build -t web_ocp:v1 .
# crear tag para subir :  docker tag web_ocp:v1  rocha7778/ocp_web:v1.0
# subir imagen: docker push rocha7778/ocp_web:v1.0
# docker create -p 8083:8082 --name webserverv2  web_ocp
# subir imagen a ocp:  oc import-image rocha7778/ocp_web:v1.0 --confirm
#
# docker start webserver
# _build/prod/rel/web_server/bin/web_server start
