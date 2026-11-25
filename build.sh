#!/usr/bin/env bash
#
# Build the essay.
#
#   ./build.sh              auto: pdflatex+biber if installed, else Tectonic preview
#   ./build.sh --canonical  force pdflatex + biber (the submission toolchain)
#   ./build.sh --preview    force Tectonic (XeTeX + BibTeX), for machines without TeX Live
#   ./build.sh --clean      remove build/ and exit
#
# Deterministic by construction:
#   * build/ is wiped and restaged from paper/ on every run, so no stale state;
#   * the document date is pinned to the last commit that touched paper/
#     (SOURCE_DATE_EPOCH), so rebuilding the same commit gives the same PDF;
#   * TZ and locale are fixed, and the number of TeX passes is fixed;
#   * the preview patch is asserted, not best-effort: if paper/main.tex changes
#     shape the script fails loudly instead of emitting a half-patched document.
#
# paper/ is never modified. The canonical build is what gets submitted; the
# preview build differs only in the bibliography engine (natbib instead of
# biblatex/biber) and in omitting an abstract that has not been written yet.

set -euo pipefail

cd "$(dirname "$0")"
SRC="paper"
OUT="build"

# ---------------------------------------------------------------- arguments
MODE="auto"
for arg in "$@"; do
  case "$arg" in
    --canonical) MODE="canonical" ;;
    --preview)   MODE="preview" ;;
    --clean)     rm -rf "$OUT"; echo "removed $OUT/"; exit 0 ;;
    -h|--help)   sed -n '3,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)           echo "build.sh: unknown option $arg" >&2; exit 2 ;;
  esac
done

# ------------------------------------------------------------ determinism
export TZ=UTC LC_ALL=C

if EPOCH=$(git log -1 --format=%ct -- "$SRC" 2>/dev/null) && [ -n "$EPOCH" ]; then
  DATE_SOURCE="last commit touching $SRC/"
else
  EPOCH=$(date +%s)
  DATE_SOURCE="current time, no git history -- not reproducible"
fi
export SOURCE_DATE_EPOCH="$EPOCH"
export FORCE_SOURCE_DATE=1

# ------------------------------------------------------------ toolchain
have() { command -v "$1" >/dev/null 2>&1; }

CANONICAL_OK=0
if have pdflatex && have biber; then CANONICAL_OK=1; fi

if [ "$MODE" = "auto" ]; then
  if [ "$CANONICAL_OK" = 1 ]; then MODE="canonical"; else MODE="preview"; fi
fi

if [ "$MODE" = "canonical" ] && [ "$CANONICAL_OK" = 0 ]; then
  echo "build.sh: --canonical needs pdflatex and biber" >&2
  echo "          install TeX Live/MacTeX, or run --preview" >&2
  exit 1
fi
if [ "$MODE" = "preview" ] && ! have tectonic; then
  echo "build.sh: tectonic not found (brew install tectonic)" >&2
  exit 1
fi

# ------------------------------------------------------------ stage
rm -rf "$OUT"
mkdir -p "$OUT"
cp -R "$SRC/." "$OUT/"

LOG="$OUT/build.log"
CHK="$OUT/main.log"
: > "$LOG"

# ------------------------------------------------------------ preview patch
if [ "$MODE" = "preview" ]; then
  python3 - "$OUT/main.tex" "$OUT/sections/00-abstract.tex" <<'PY'
import re, sys

main_path, abstract_path = sys.argv[1], sys.argv[2]
s = open(main_path).read()
fail = []

# 1. biblatex+biber -> natbib+plainnat. Tectonic ships BibTeX, not Biber.
bib_in = ("\\usepackage[backend=biber,style=numeric-comp,sorting=nyt,maxbibnames=6]{biblatex}\n"
          "\\addbibresource{refs.bib}")
if bib_in not in s:
    fail.append("bibliography preamble: biblatex+biber block not found")
else:
    s = s.replace(bib_in, "\\usepackage[numbers,sort&compress]{natbib}")

prt_in = "\\printbibliography[heading=bibintoc,title={References}]"
prt_out = ("\\renewcommand{\\refname}{References}\n"
           "\\bibliographystyle{plainnat}\n"
           "\\bibliography{refs}")
if prt_in not in s:
    fail.append("bibliography tail: \\printbibliography not found")
else:
    s = s.replace(prt_in, prt_out)

# 2. Omit the abstract input while the abstract is still empty, detected by
#    counting real words so it returns automatically once it is written.
abs_src = open(abstract_path).read()
body = re.sub(r'(?m)(?<!\\)%.*$', '', abs_src)
body = re.sub(r'\\[a-zA-Z@]+\*?(\[[^\]]*\])?(\{[^{}]*\})?', ' ', body)
words = re.sub(r'[{}]', ' ', body).split()
if len(words) < 20:
    s = s.replace("\\input{sections/00-abstract}", "% abstract omitted: not yet written")
    omitted = True
else:
    omitted = False

open(main_path, 'w').write(s)
for f in fail:
    print("PATCH FAILED:", f, file=sys.stderr)
print("abstract", "omitted" if omitted else "included")
sys.exit(1 if fail else 0)
PY
fi

# ------------------------------------------------------------ compile
echo "mode:    $MODE"
echo "date:    $(date -u -r "$EPOCH" '+%Y-%m-%d') ($DATE_SOURCE)"
echo

if [ "$MODE" = "canonical" ]; then
  ver="$(pdflatex --version | head -1 | cut -d' ' -f1-2), $(biber --version | head -1 | cut -d' ' -f1-2)"
  echo "engine:  $ver"
  (
    cd "$OUT"
    pdflatex -interaction=nonstopmode -halt-on-error -file-line-error main.tex >/dev/null
    biber main >/dev/null
    pdflatex -interaction=nonstopmode -halt-on-error -file-line-error main.tex >/dev/null
    pdflatex -interaction=nonstopmode -halt-on-error -file-line-error main.tex >/dev/null
  ) || { echo "compile failed; tail of log:" >&2; tail -n 25 "$OUT/main.log" >&2; exit 1; }
else
  echo "engine:  $(tectonic --version | sed 's/Tectonic.*//;s/ *$//')"
  # Pass one seeds .aux/.bbl; its warnings are noise. Pass two is the build.
  ( cd "$OUT" && tectonic -X compile --keep-logs main.tex ) >"$LOG" 2>&1 ||
    { echo "compile failed; tail of log:" >&2; tail -n 25 "$LOG" >&2; exit 1; }
  ( cd "$OUT" && tectonic -X compile --keep-logs main.tex ) >"$LOG" 2>&1 ||
    { echo "compile failed; tail of log:" >&2; tail -n 25 "$LOG" >&2; exit 1; }
fi

[ -f "$CHK" ] || CHK="$LOG"

echo "output:  $OUT/main.pdf ($(du -h "$OUT/main.pdf" | cut -f1 | tr -d ' '))"

# ------------------------------------------------------------ checks
STATUS=0

refs=$(grep -oE "Reference \`[^']*" "$CHK" 2>/dev/null | sed "s/Reference \`//" | sort -u || true)
cites=$(grep -oE "Citation \`[^']*" "$CHK" 2>/dev/null | sed "s/Citation \`//" | sort -u || true)

figures=$(printf '%s\n' "$refs" | grep '^fig:' || true)
broken=$(printf '%s\n' "$refs" | grep -v '^fig:' | grep . || true)

[ -n "$figures" ] && echo "pending: figures not drawn yet: $(printf '%s ' $figures)"
if [ -n "$broken" ]; then
  echo "BROKEN:  unresolved reference(s): $(printf '%s ' $broken)"
  STATUS=1
fi
if [ -n "$cites" ]; then
  echo "BROKEN:  undefined citation(s): $(printf '%s ' $cites)"
  STATUS=1
fi

# Citation keys must exist in refs.bib, checked independently of the engine.
python3 - "$OUT" <<'PY' || STATUS=1
import glob, re, sys
out = sys.argv[1]
used = set()
for f in glob.glob(out + '/sections/*.tex'):
    for k in re.findall(r'\\cite\{([^}]*)\}', open(f).read()):
        used |= {x.strip() for x in k.split(',') if x.strip()}
defined = set(re.findall(r'^@[a-zA-Z]+\{([^,]+),', open(out + '/refs.bib').read(), re.M))
missing = sorted(used - defined)
if missing:
    print("BROKEN:  cited but missing from refs.bib:", ', '.join(missing))
    sys.exit(1)
unused = sorted(defined - used)
print("cites:   %d of %d keys used" % (len(used), len(defined)))
if unused:
    print("unused:  " + ', '.join(unused))
PY

if grep -rq '\[\[CITE:' "$OUT"/sections/*.tex 2>/dev/null; then
  echo "todo:    unresolved [[CITE: ...]] markers:"
  grep -rn '\[\[CITE:' "$OUT"/sections/*.tex | sed 's/^/           /'
fi

if have pdftotext; then
  echo "pages:   $(pdftotext "$OUT/main.pdf" - | awk 'BEGIN{p=1} /\f/{p++} END{print p}')"
fi
echo "typeset: $(grep -c 'Overfull\|Underfull' "$CHK" 2>/dev/null || echo 0) overfull/underfull warnings"

echo
if [ "$STATUS" = 0 ]; then
  echo "ok        ->  $OUT/main.pdf"
else
  echo "failed:   see $CHK" >&2
fi
exit "$STATUS"
