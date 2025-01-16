%{
  configs: [
    %{
      name: "default",
      checks: %{
        disabled: [
          {Credo.Check.Consistency.ExceptionNames, false}
        ]
      }
    }
  ]
}
