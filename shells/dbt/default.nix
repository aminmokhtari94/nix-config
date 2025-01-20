{ pkgs, mkShell, ... }:

mkShell {
  packages = with pkgs; [
    dbt
    postgresql
    (python314.withPackages (python-pkgs: [ ]))
  ];
  shellHook = ''
    python -m venv .venv
    source .venv/bin/activate
    python -m pip install dbt-risingwave dbt-clickhouse
  '';
}
