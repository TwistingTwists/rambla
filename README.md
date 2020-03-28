# Rambla

![Test](https://github.com/am-kantox/rambla/workflows/Test/badge.svg)  ![Dialyzer](https://github.com/am-kantox/rambla/workflows/Dialyzer/badge.svg)  **Easy publishing to many different targets**

## Installation

```elixir
def deps do
  [
    {:rambla, "~> 0.4"}
  ]
end
```

## Supported back-ends

- Rabbit (through [Amqp](https://hexdocs.pm/amqp/))
- Redis (through [Exredis](https://hexdocs.pm/exredis))
- Http (through [:httpc](http://erlang.org/doc/man/httpc.html))
- Smtp (through [:gen_smtp](https://hexdocs.pm/gen_smtp))
- Slack (through [Envío](https://hexdocs.pm/envio))

## Coming soon

- AWS

## Changelog

-  **`0.6.0`** `mix` tasks to deal with RabbitMQ
-  **`0.5.2`** graceful timeout, fix for optional `Envio` does not included
-  **`0.5.1`** performance fixes, do not require `queue` in call to Rabbit `publish/2`, `declare?: false` to not declare exchange every time
-  **`0.5.0`** bulk publisher
-  **`0.4.0`** `SMTP` publisher
-  **`0.3.0`** `HTTP` publisher

## Documentation

- [https://hexdocs.pm/rambla](https://hexdocs.pm/rambla).
