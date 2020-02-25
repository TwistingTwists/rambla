defmodule Rambla.ConnectionPool do
  @moduledoc false
  use DynamicSupervisor

  @notify_broadcast Application.get_env(:rambla, :notify_broadcast, true)

  if @notify_broadcast do
    use Envio.Publisher
  else
    defmacrop broadcast(_, _), do: :ok
  end

  @spec start_link(opts :: keyword) :: Supervisor.on_start()
  def start_link(opts \\ []),
    do: DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)

  @impl DynamicSupervisor
  def init(opts), do: DynamicSupervisor.init(Keyword.put_new(opts, :strategy, :one_for_one))

  @spec start_pools() :: [DynamicSupervisor.on_start_child()]
  def start_pools() do
    start_pools(
      for {k, v} <- Application.get_env(:rambla, :pools, []), do: {fix_type(k), params: v}
    )
  end

  @spec start_pools(%{required(atom()) => keyword()} | keyword()) :: [
          DynamicSupervisor.on_start_child()
        ]
  def start_pools(opts) do
    Enum.map(opts, fn {type, opts} ->
      with {options, opts} <- Keyword.pop(opts, :options, []),
           {worker_type, opts} <- Keyword.pop(opts, :type, :local),
           {worker_name, opts} <- Keyword.pop(opts, :name, type),
           {params, []} <- Keyword.pop(opts, :params, []) do
        worker =
          Keyword.merge(
            options,
            name: {worker_type, worker_name},
            worker_module: Rambla.Connection
          )

        child_spec = :poolboy.child_spec(Rambla.Connection, worker, {worker_name, params})
        DynamicSupervisor.start_child(Rambla.ConnectionPool, child_spec)
      end
    end)
  end

  @spec pools :: [{:undefined, pid() | :restarting, :worker | :supervisor, [:poolboy]}]
  def pools, do: DynamicSupervisor.which_children(Rambla.ConnectionPool)

  @spec publish(type :: atom(), message :: map(), opts :: map()) ::
          Rambla.Connection.outcome()
  def publish(type, %{} = message, opts \\ %{}) do
    type = fix_type(type)

    response = :poolboy.transaction(type, &GenServer.call(&1, {:publish, message, opts}))
    broadcast(type, %{message: message, response: response})
    response
  end

  @spec conn(type :: atom()) :: any()
  def conn(type),
    do: type |> fix_type() |> :poolboy.transaction(&GenServer.call(&1, :conn))

  @spec fix_type(k :: binary() | atom()) :: module()
  defp fix_type(k) when is_binary(k), do: String.to_existing_atom(k)

  defp fix_type(k) when is_atom(k) do
    case to_string(k) do
      "Elixir." <> _ -> k
      short_name -> Module.concat("Rambla", Macro.camelize(short_name))
    end
  end
end
