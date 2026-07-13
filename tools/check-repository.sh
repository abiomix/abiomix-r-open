#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
status=0
package_count=0

while IFS= read -r -d '' package_dir; do
  package_count=$((package_count + 1))
  package_name="$(basename "$package_dir")"

  for required in DESCRIPTION NAMESPACE UPSTREAM.dcf UPSTREAM.md COMMERCIAL-LICENSE.md; do
    if [[ ! -f "$package_dir/$required" ]]; then
      printf 'missing %s/%s\n' "$package_name" "$required" >&2
      status=1
    fi
  done

  if [[ -f "$package_dir/DESCRIPTION" ]]; then
    declared="$(sed -n 's/^Package:[[:space:]]*//p' "$package_dir/DESCRIPTION" | head -n 1)"
    if [[ "$declared" != "$package_name" ]]; then
      printf 'package directory/name mismatch: %s declares %s\n' "$package_name" "$declared" >&2
      status=1
    fi

    if ! grep -q 'Sounkou Mahamane' "$package_dir/DESCRIPTION" ||
       ! grep -q 'family[[:space:]]*=[[:space:]]*"Toure"' "$package_dir/DESCRIPTION"; then
      printf 'missing required author Sounkou Mahamane Toure: %s\n' "$package_name" >&2
      status=1
    fi

    if ! grep -q 'Abiomix FZ LLC' "$package_dir/DESCRIPTION" ||
       ! grep -Eq 'role[[:space:]]*=[[:space:]]*c\([^)]*"cph"[^)]*"fnd"|role[[:space:]]*=[[:space:]]*c\([^)]*"fnd"[^)]*"cph"' "$package_dir/DESCRIPTION"; then
      printf 'missing Abiomix FZ LLC cph/fnd attribution: %s\n' "$package_name" >&2
      status=1
    fi

    if ! grep -Eq '^License:[[:space:]]*GPL[[:space:]]*\(>=[[:space:]]*[23]\)' "$package_dir/DESCRIPTION"; then
      printf 'public package license must be GPL (>= 2) or GPL (>= 3): %s\n' "$package_name" >&2
      status=1
    fi

    if ! grep -q '^Config/abiomix/public-license:' "$package_dir/DESCRIPTION" ||
       ! grep -q '^Config/abiomix/commercial-license:' "$package_dir/DESCRIPTION" ||
       ! grep -q '^Config/abiomix/license-policy:' "$package_dir/DESCRIPTION"; then
      printf 'missing dual-license metadata: %s\n' "$package_name" >&2
      status=1
    fi
  fi

  if ! find "$package_dir" -maxdepth 1 -type f \( -name 'LICENSE' -o -name 'LICENSE.md' -o -name 'LICENSE.txt' \) -print -quit | grep -q .; then
    printf 'missing package license: %s\n' "$package_name" >&2
    status=1
  fi
done < <(find "$root/packages" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

printf 'checked %d package director%s\n' "$package_count" "$([[ $package_count -eq 1 ]] && printf y || printf ies)"
exit "$status"
