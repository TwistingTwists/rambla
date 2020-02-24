defmodule Rambla.Smtp do
  @moduledoc """
  Default connection implementation for 📧 SMTP.
  """
  @behaviour Rambla.Connection

  @conn_params ~w|relay username password auth ssl tls tls_options hostname retries|a

  @impl Rambla.Connection
  def connect(params) when is_list(params) do
    if is_nil(params[:hostname]),
      do:
        raise(Rambla.Exceptions.Connection,
          value: params,
          expected: "📧 configuration with :host key"
        )

    [defaults, opts] =
      params
      |> Keyword.split(@conn_params)
      |> Tuple.to_list()
      |> Enum.map(&Map.new/1)

    %Rambla.Connection{
      conn: %{conn: params[:hostname], opts: opts, defaults: defaults},
      conn_type: __MODULE__,
      conn_pid: self(),
      conn_params: params,
      errors: []
    }
  end

  @impl Rambla.Connection
  def publish(%{conn: conn, opts: opts, defaults: defaults}, message) when is_binary(message),
    do: publish(%{conn: conn, opts: opts, defaults: defaults}, Jason.decode!(message))

  @impl Rambla.Connection
  def publish(%{conn: _conn, opts: opts, defaults: defaults}, message)
      when is_map(opts) and is_map(message) do
    IO.inspect({opts, message}, label: "MSG")
    {to, message} = Map.pop(message, :to)
    {from, message} = Map.pop(message, :from, Map.get(opts, :from, []))
    {subject, message} = Map.pop(message, :subject, Map.pop(opts, :subject, ""))
    {body, _message} = Map.pop(message, :body, Map.pop(opts, ""))

    smtp_message =
      ["Subject: ", "From: ", "To: ", "\r\n"]
      |> Enum.zip([subject, from, to, body])
      |> Enum.map(&(&1 |> Tuple.to_list() |> Enum.join()))
      |> Enum.join("\r\n")
      |> IO.inspect(label: "MSG")

    :gen_smtp_client.send(
      {to, from, smtp_message},
      defaults
      |> Map.merge(Map.take(opts, @conn_params))
      |> Map.to_list()
    )
  end
end
