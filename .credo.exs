%{
  configs: [
    %{
      name: "default",
      checks: %{
        disabled: [
          {Credo.Check.Design.TagTODO, false},
          {Credo.Check.Consistency.ExceptionNames, false},
          {Credo.Check.Refactor.CyclomaticComplexity, max_complexity: 15},
        ]
      }
    }
  ]
}
