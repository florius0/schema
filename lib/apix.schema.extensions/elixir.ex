defmodule Apix.Schema.Extensions.Elixir do
  alias Apix.Schema

  alias Apix.Schema.Extension

  alias Apix.Schema.Ast
  alias Apix.Schema.Context

  alias Apix.Schema.Extensions.Elixir.Atom
  alias Apix.Schema.Extensions.Elixir.String
  alias Apix.Schema.Extensions.Elixir.Integer
  alias Apix.Schema.Extensions.Elixir.Float
  alias Apix.Schema.Extensions.Elixir.Number
  alias Apix.Schema.Extensions.Elixir.Tuple
  alias Apix.Schema.Extensions.Elixir.List
  alias Apix.Schema.Extensions.Elixir.Map
  alias Apix.Schema.Extensions.Elixir.Struct
  alias Apix.Schema.Extensions.Elixir.Record
  alias Apix.Schema.Extensions.Elixir.MapSet
  alias Apix.Schema.Extensions.Elixir.Range
  alias Apix.Schema.Extensions.Elixir.Function
  alias Apix.Schema.Extensions.Elixir.Module
  alias Apix.Schema.Extensions.Elixir.PID
  alias Apix.Schema.Extensions.Elixir.Port
  alias Apix.Schema.Extensions.Elixir.Reference
  alias Apix.Schema.Extensions.Elixir.Date
  alias Apix.Schema.Extensions.Elixir.Time
  alias Apix.Schema.Extensions.Elixir.DateTime
  alias Apix.Schema.Extensions.Elixir.NaiveDateTime
  alias Apix.Schema.Extensions.Elixir.Regex
  alias Apix.Schema.Extensions.Elixir.URI
  alias Apix.Schema.Extensions.Elixir.Version
  alias Apix.Schema.Extensions.Elixir.Version

  @manifest %Extension{
    module: __MODULE__,
    delegates: [
      {
        {Elixir.Atom, :t},
        {Atom, :t}
      },
      {
        {Elixir.String, :t},
        {String, :t}
      },
      {
        {Elixir.Integer, :t},
        {Integer, :t}
      },
      {
        {Elixir.Integer, :non_neg},
        {Integer, :non_neg}
      },
      {
        {Elixir.Float, :t},
        {Float, :t}
      },
      {
        {Elixir.Number, :t},
        {Number, :t}
      },
      {
        {Elixir.Tuple, :t},
        {Tuple, :t}
      },
      {
        {Elixir.List, :t},
        {List, :t}
      },
      {
        {Elixir.Map, :t},
        {Map, :t}
      },
      {
        {Elixir.Struct, :t},
        {Struct, :t}
      },
      {
        {Elixir.Record, :t},
        {Record, :t}
      },
      {
        {Elixir.MapSet, :t},
        {MapSet, :t}
      },
      {
        {Elixir.Range, :t},
        {Range, :t}
      },
      {
        {Elixir.Function, :t},
        {Function, :t}
      },
      {
        {Elixir.Module, :t},
        {Module, :t}
      },
      {
        {Elixir.PID, :t},
        {PID, :t}
      },
      {
        {Elixir.Port, :t},
        {Port, :t}
      },
      {
        {Elixir.Reference, :t},
        {Reference, :t}
      },
      {
        {Elixir.Date, :t},
        {Date, :t}
      },
      {
        {Elixir.Date.Range, :t},
        {Date.Range, :t}
      },
      {
        {Elixir.Time, :t},
        {Time, :t}
      },
      {
        {Elixir.DateTime, :t},
        {DateTime, :t}
      },
      {
        {Elixir.NaiveDateTime, :t},
        {NaiveDateTime, :t}
      },
      {
        {Elixir.Regex, :t},
        {Regex, :t}
      },
      {
        {Elixir.URI, :t},
        {URI, :t}
      },
      {
        {Elixir.Version, :t},
        {Version, :t}
      },
      {
        {Elixir.Version.Requirement, :t},
        {Version.Requirement, :t}
      }
    ]
  }

  @moduledoc """
  Defines `#{inspect Schema}` Extension to support Elixir types.

  #{Extension.delegates_doc(@manifest)}

  ## Expressions

  - `item`
  - `rest`
  - `field`
  """

  @behaviour Extension

  @impl Extension
  def manifest, do: @manifest

  @impl Extension
  def expression!(context, {:item, _, elixir_ast}, schema_ast, _literal?) do
    type = Context.inner_expression!(context, elixir_ast, %Ast{})

    Ast.add_keyword_args(schema_ast, item: type)
  end

  def expression!(context, {:rest, _, elixir_ast}, schema_ast, _literal?) do
    type = Context.inner_expression!(context, elixir_ast, %Ast{})

    Ast.add_keyword_args(schema_ast, rest: type)
  end

  def expression!(context, {:field, _, elixir_ast}, schema_ast, _literal?) do
    {key_type, value_type} =
      if match?([do: {:__block__, _, [{:key, _, _}, {:value, _, _} | _]}], Elixir.List.last(elixir_ast)) do
        {
          flags,
          [[do: {:__block__, _, [{:key, _, key_elixir_ast}, {:value, _, value_elixir_ast} | _]}]]
        } = Enum.split(elixir_ast, -1)

        {
          Context.inner_expression!(context, key_elixir_ast, %Ast{}),
          context
          |> Context.inner_expression!(value_elixir_ast, %Ast{})
          |> struct(flags: Elixir.List.flatten(flags))
        }
      else
        [
          key_elixir_ast
          | value_elixir_ast
        ] = elixir_ast

        {
          Context.inner_expression!(context, [key_elixir_ast], %Ast{}),
          Context.inner_expression!(context, value_elixir_ast, %Ast{})
        }
      end

    Ast.add_keyword_args(schema_ast, field: {key_type, value_type})
  end

  def expression!(_context, _ast, _schema_ast, _literal?), do: false
end
