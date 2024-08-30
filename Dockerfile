FROM elixir:1.5.2

EXPOSE 4000
ENV APP_NAME=db_migrator \
    MIX_ENV=prod

WORKDIR /$APP_NAME

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get install -y -q nodejs && \
    mix do local.hex --force, local.rebar --force && \
    mkdir -p /$APP_NAME && \
    mkdir -p /$APP_NAME/priv/static

COPY mix.* /$APP_NAME/

RUN mix do deps.get, compile, phx.digest

COPY . /$APP_NAME/

RUN cd /$APP_NAME/assets && \
    npm install && \
    node /$APP_NAME/assets/node_modules/brunch/bin/brunch build

RUN mix do release.init, release

CMD REPLACE_OS_VARS=true MIX_ENV=$MIX_ENV _build/$MIX_ENV/rel/$APP_NAME/bin/$APP_NAME foreground
