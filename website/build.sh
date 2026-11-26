#!/usr/bin/env bash
# Copies repo content into website/docs and normalizes it for MkDocs + mkdocs-static-i18n.
# The repo stays browsable on GitHub (README.md / *.pt-BR.md); the site gets index.md / *.pt.md.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/website/docs"
rm -rf "$OUT"; mkdir -p "$OUT"

SECTIONS="00-fundamentals 01-frameworks 02-prompt-injection 03-output-attacks 04-data-attacks
05-app-and-system 06-evasion 07-privacy 08-defense labs tools methodology cheatsheets writeups"

for d in $SECTIONS; do
  # markdown + images only; lab source code (app/) is not published on the site
  rsync -a --prune-empty-dirs --exclude 'app/' \
    --include '*/' --include '*.md' --include '*.png' --include '*.jpg' --include '*.svg' --include '*.gif' \
    --exclude '*' "$ROOT/$d/" "$OUT/$d/"
done
cp "$ROOT/DISCLAIMER.md" "$ROOT/SECURITY.md" "$OUT/"
cp -r "$ROOT/website/assets" "$OUT/assets"
cp "$ROOT/website/home/"*.md "$OUT/"

# README.md -> index.md, *.pt-BR.md -> *.pt.md
find "$OUT" -name '*.md' | while read -r f; do
  dir=$(dirname "$f"); base=$(basename "$f")
  new=${base/README/index}; new=${new/.pt-BR.md/.pt.md}
  if [ "$base" != "$new" ]; then mv "$f" "$dir/$new"; fi
done

# Rewrite links and drop the manual language-switch lines (the site has its own selector)
find "$OUT" -name '*.md' -exec sed -i -E \
  -e 's#README(\.pt-BR)?\.md#index\1.md#g' \
  -e 's#\.pt-BR\.md#.pt.md#g' \
  -e 's|\]\(([^):#]*)/\)|](\1/index.md)|g' \
  -e '/^> 🇺🇸 English · 🇧🇷/d' \
  -e '/^> 🇧🇷 Português · 🇺🇸/d' {} +

# GitHub alerts (> [!TIP]) -> Material admonitions (!!! tip "Title").
# A bold first line inside the alert (> **Title**) becomes the admonition title.
find "$OUT" -name '*.md' -exec perl -0pi -e '
  my %t = (NOTE=>"note", TIP=>"tip", IMPORTANT=>"info", WARNING=>"warning", CAUTION=>"danger");
  s{^> \[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\][ \t]*\n((?:>.*(?:\n|\z))*)}{
    my ($k, $b) = ($1, $2); my $title = "";
    if ($b =~ s/\A> ?\*\*(.+?)\*\*[ \t]*\n//) { $title = " \"$1\""; }
    $b =~ s/^> ?/    /mg;
    "!!! $t{$k}$title\n$b\n"
  }gme' {} +

echo "Site content ready in $OUT"
