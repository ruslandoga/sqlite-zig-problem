defmodule E do
  alias Exqlite.Sqlite3

  defp load(ext) do
    {:ok, conn} = Sqlite3.open(":memory:")
    :ok = Sqlite3.enable_load_extension(conn, true)
    :ok = Sqlite3.execute(conn, "select load_extension('#{ext}')")
    :ok = Sqlite3.enable_load_extension(conn, false)
    conn
  end

  defp exec(conn, sql) do
    {:ok, stmt} = Sqlite3.prepare(conn, sql)
    {:row, row} = Sqlite3.step(conn, stmt)
    :done = Sqlite3.step(conn, stmt)
    row
  end

  @sumc "with recursive ten(x) as (select 1 union all select x+100 from ten where x<1000) select sumc(x) from ten"
  @sumzig "with recursive ten(x) as (select 1 union all select x+100 from ten where x<1000) select sumzig(x) from ten"

  def sumc do
    conn = load("dist/extc")
    exec(conn, @sumc)
  end

  def sumzig do
    conn = load("dist/extzig")
    exec(conn, @sumzig)
  end
end
