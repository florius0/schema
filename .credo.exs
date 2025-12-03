%{
  configs: [
    %{
      name: "default",
      checks: %{
        enabled: [
          {Credo.Check.Refactor.Nesting, max_nesting: 3},
          {Credo.Check.Refactor.CyclomaticComplexity, max_complexity: 15}
        ],
        disabled: [
          {Credo.Check.Consistency.ExceptionNames, false},
          {Credo.Check.Design.TagTODO, false},
          {Credo.Check.Readability.WithSingleClause, false}
        ]
      }
    }
  ]
}
