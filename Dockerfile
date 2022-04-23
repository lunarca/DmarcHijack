FROM elixir:latest

RUN mkdir /app
WORKDIR /app
COPY . .

RUN mix local.hex --force
RUN mix deps.get
