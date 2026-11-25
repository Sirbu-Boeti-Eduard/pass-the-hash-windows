#!/usr/bin/env bash
# Local preview build.
#
# The canonical build is pdflatex + biber (see README). That toolchain is not
# installed on this machine, so this script produces a readable PDF with
# Tectonic instead, patching two things in a scratch copy:
#
#   1. biblatex+biber -> natbib+plainnat, because Tectonic ships BibTeX only.
#      Citation numbering is identical; only the bibliography style differs.
#   2. the abstract is left out until it is written.
#
# Nothing here changes paper/ -- the submitted source stays pdflatex+biber.
set -euo pipefail

cd "$(dirname "$0")"
rm -rf build
mkdir -p build
cp -r paper/* build/

python3 - <<'PY'
p = 'build/main.tex'
s = open(p).read()
s = s.replace(
    "\\usepackage[backend=biber,style=numeric-comp,sorting=nyt,maxbibnames=6]{biblatex}\n"
    "\\addbibresource{refs.bib}",
    "\\usepackage[numbers,sort&compress]{natbib}")
s = s.replace(
    "\\printbibliography[heading=bibintoc,title={References}]",
    "\\renewcommand{\\refname}{References}\n"
    "\\bibliographystyle{plainnat}\n"
    "\\bibliography{refs}")
s = s.replace("\\input{sections/00-abstract}", "% abstract omitted until written")
assert 'natbib' in s and 'bibliography{refs}' in s
open(p, 'w').write(s)
PY

cd build
tectonic -X compile main.tex >/dev/null
tectonic -X compile main.tex >/dev/null
echo "built: build/main.pdf"
