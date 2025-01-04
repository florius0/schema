# Apix.Schema

Apix.Schema is a sophisticated Elixir library designed with the new set-theoretic type system in mind and inspired by Higher-Kinded Types. It facilitates the definition of complex data schemas, complete with extensive validations and type inference capabilities. The library excels in creating structured data types with advanced features like pattern matching, custom validators, and dynamic type inference. A notable feature of Apix.Schema is its ability to export schemas into multiple formats, enhancing its utility in various data modeling and API development scenarios. Additionally, it offers an extensible architecture, allowing for custom extensions that can further tailor its functionality.

## Example

```elixir
defmodule Api.Data do
  # schema named :id of type integer
  schema id: Integer.t() do
    # validates the value to be >= 0
    validate it >= 0
  end

  # schema with dependent type
  schema t: Integer.t(), params: [:x] do
    validate it >= x
  end

  # Intersection type example: Schema a and b
  schema a: Integer.t() when it >= 5
  schema b: Integer.t() when it >= 10
  schema c: a() and b() # when it >= 10 and >= 5

  # Variant or tagged union example: either ok or error
  schema ok: {:ok, data()}, params: [:data]
  schema error: {:error, Any.t()}
  schema either: ok() or error()

  # schema named :data of type Struct.t(). The struct must be __MODULE__
  schema data: Struct.t() do
    # field of type id, defined earlier in this module
    field :id, id()

    # field of type Integer.t() or type String.t() or nil
    field :b, Integer.t() or String.t() or nil

    # inline schema of type map
    field :c, Map.t() do
      # field of type Any.t()
      field :d, Any.t()

      field do
         key :e
         value Any.t()
      end

      # field that matches pattern
      field do
         key String.t() do
            validate Regex.match(it, ~r/123/)
         end

         value Any.t()
      end

      # field of type Any.t() that has Integer.t() values
      field do
         key Any.t()
         value Integer.t()
      end
    end

    # validates field :b to be >= 42 when b is subtype of integer
    validate it.b >= 42 when is_subtype(it.b, Integer.t())

    # validates field :b to be of length >= 2 when b is exactly of type String.t()
    validate do
      x = length(it.b)
      x >= 2 when it.b = Integer.t()
    end

    # validates field :d in field :c matches regex
    validate it.c.d =~ ~r/a.*z/

    # validates all fields that match pattern against custom validators
    validate pattern_field(it, ~r/123/) |> custom_validator()
  end

  def custom_validator(42), do: :ok
  def custom_validator(_x), do: {:error, "invalid data"}
end

defmodule Api.Error do
  # this schema has parameter :type with default value String.t()
  schema t: Struct.t(), params: [type: String.t()] do
    # field of type type()
    field :type, type()

    # field of type String.t()
    field :comment, String.t()

    # validates that type() can be casted to String.t()
    validate is_castable(type(), String.t())
  end
end

defmodule Api.Response do
  # schema named :t of type Struct.t()
  schema t: Struct.t(), params: [:data, error: Api.Error.t()] do
    # field of type data()
    field :data, data()

    # field with type List.t() of error()
    field :errors, List.t(error())

    # validates that error() is subtype of Api.Error.t()
    validate is_subtype(error(), Api.Error.t())
  end
end

defmodule Api.Responses do
  # schema named :t of type List.t()
  schema t: List.t() do
    # Rest elements of List.t() must be of type Api.Response.t(auto())
    rest Api.Response.t(auto())
  end
end
```

## Documentation Outline

1. **Introduction**
   - Overview of `Apix.Schema`
   - Design philosophy with set-theoretic type system
   - Key features and capabilities

2. **Getting Started**
   - Installation and basic setup
   - Initial schema creation example

3. **Core Concepts**
   - Overview of set-theoretic type system
   - Schema definition and type system

4. **Defining Schemas**
   - Detailed guide on schema definitions
   - Field and type definitions
   - Inline schema and validation rules

5. **Validations and Constraints**
   - Adding and managing validations
   - Custom validators and type casting

6. **Advanced Features**
   - Type inference with `auto()`
   - Parameterized schemas
   - Pattern fields and multi-line validators

7. **Exporting Schemas**
   - Export capabilities overview
   - Supported formats and examples

8. **Best Practices**
   - Effective schema design tips
   - Performance and error handling

9. **API Reference**
   - Complete function and module documentation

10. **Examples and Use Cases**
    - Real-world application examples

11. **FAQs and Troubleshooting**
    - Common questions and issues

12. **Extending `Apix.Schema`**
    - Overview of extension architecture
    - Creating and integrating custom extensions
    - Extension API (`Apix.Schema.Extension` module details)

13. **Changelog and Versions**
    - Revision history and version information

## Roadmap

1. **Short-Term Goals (3-6 months)**
   - Core API finalization and stabilization
   - Comprehensive documentation, focusing on set-theoretic concepts
   - Basic export functionality implementation

   - [x] expressions (`Apix.Schema.Core`)
   - [x] elixir types (`Apix.Schema.Elixir`)
   - [ ] mix check & refactoring
   - [ ] type casting
   - [ ] imports/exports extension architecture
   - [ ] building functions in compile time relying on pattern-matching
   - [ ] docs

2. **Mid-Term Goals (6-12 months)**
   - Advanced export format support
   - Performance optimization for complex schemas
   - User feedback integration and API iteration

3. **Long-Term Goals (1-2 years)**
   - Advanced type system features exploration
   - Elixir community integration and extensions
   - Contributor community establishment for library extension

4. **Continuous Objectives**
   - Regular updates and maintenance
   - Continuous documentation improvements
   - Community engagement and support
