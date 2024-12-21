[
  tools: [
    {
      :compiler,
      ".check/tools/compiler.sh",
      enabled: true
    },
    {
      :unused_deps,
      ".check/tools/unused_deps.sh",
      enabled: true, detect: [{:elixir, ">= 1.10.0"}], fix: "mix deps.unlock --unused"
    },
    {
      :formatter,
      ".check/tools/formatter.sh",
      enabled: true, detect: [{:file, ".formatter.exs"}], fix: "mix format"
    },
    {
      :mix_audit,
      ".check/tools/mix_audit.sh",
      enabled: true, detect: [{:package, :mix_audit}]
    },
    {
      :credo,
      ".check/tools/credo.sh",
      enabled: true, detect: [{:package, :credo}]
    },
    {
      :doctor,
      ".check/tools/doctor.sh",
      enabled: true, detect: [{:package, :doctor}, {:elixir, ">= 1.8.0"}]
    },
    {
      :sobelow,
      ".check/tools/sobelow.sh",
      enabled: true, umbrella: [recursive: true], detect: [{:package, :sobelow}]
    },
    {
      :ex_doc,
      ".check/tools/ex_doc.sh",
      enabled: true, detect: [{:package, :ex_doc}]
    },
    {
      :ex_unit,
      ".check/tools/ex_unit.sh",
      enabled: true, detect: [{:file, "test"}], retry: "mix test --failed"
    },
    {
      :dialyzer,
      ".check/tools/dialyzer.sh",
      enabled: true, detect: [{:package, :dialyxir}]
    },
    {
      :gettext,
      ".check/tools/gettext.sh",
      enabled: false, detect: [{:package, :gettext}], deps: [:ex_unit]
    }
  ]
]
