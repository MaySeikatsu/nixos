{ pkgs, ... }: {
  home.packages = with pkgs; [
    pre-commit

    # Batch installer: runs `pre-commit install` in every repo under the given
    # directory (default: $PWD) that has a .pre-commit-config.yaml.
    # Usage: pre-commit-install-all [root-dir]
    (writeShellApplication {
      name = "pre-commit-install-all";
      runtimeInputs = [ pre-commit git findutils ];
      text = ''
        root="''${1:-$PWD}"
        count=0
        while IFS= read -r -d "" cfg; do
          repo="$(dirname "$cfg")"
          if [ -d "$repo/.git" ] || [ -f "$repo/.git" ]; then
            printf '→ %s\n' "$repo"
            (cd "$repo" && pre-commit install --install-hooks >/dev/null) \
              && count=$((count + 1))
          fi
        done < <(find "$root" -mindepth 2 -maxdepth 4 \
                   -name .pre-commit-config.yaml -type f -print0)
        printf 'installed pre-commit hooks in %d repo(s)\n' "$count"
      '';
    })
  ];
}
