import Config

config :rambla,
  redis: [
    host: "127.0.0.1",
    port: System.get_env("REDIS_PORT", 6379),
    password: "",
    db: 0,
    reconnect: 1_000,
    max_queue: :infinity
  ],
  rabbitmq: [
    host: "localhost",
    password: "guest",
    port: System.get_env("RABBITMQ_PORT", 5672),
    username: "guest",
    virtual_host: "/",
    x_message_ttl: "4000"
  ]
