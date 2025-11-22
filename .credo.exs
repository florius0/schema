%{
  configs: [
    %{
      name: "default",
      checks: %{
        disabled: [
          {Credo.Check.Consistency.ExceptionNames, false},
          {Credo.Check.Design.TagTODO, false},
          {Credo.Check.Readability.WithSingleClause, false},
          {Credo.Check.Refactor.CyclomaticComplexity, max_complexity: 15}
        ]
      }
    }
  ]
}
