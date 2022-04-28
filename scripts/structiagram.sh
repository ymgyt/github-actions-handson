#!/bin/bash

set -o nounset
set -o pipefail
set -o errexit

CWD=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
SRC_DIR="${CWD}/../fixtures"
OUT_DIR="${CWD}/../docs/diagram"
ORG_MD="${OUT_DIR}/structiagram.md"
NEW_MD="${ORG_MD}.new"
GIT_PUSH=NO

function parse_args() {
  while [[ "$#" -gt 0 ]]; do
    case $1 in
      git-push) GIT_PUSH="YES" ;;
      *) echo "unexpected arg: $1"; exit 1 ;;
    esac
    shift
  done
}

function check_commands() {
  commands=(
    "structiagram"
    "npx"
  )

  for command in "${commands[@]}"
  do
    command -v "${command}" > /dev/null || { echo "make sure ${command} installed"; exit 1; }
  done
}

function generate_diagram() {
  # marmaid-cli failed to parse file path have '.' ex. (path/to/../file)
  # https://github.com/mermaid-js/mermaid-cli/issues/258
  cd "${OUT_DIR}"
  npx --package @mermaid-js/mermaid-cli --yes mmdc --input "structiagram.md" --output "er_diagram.svg"
  mv er_diagram-1.svg er_diagram.svg
}

function git_push() {
  local branch="er-diagram-$(date '+%Y-%m-%d-%H-%M-%S')"
  git config user.email "githubactions@example.com"
  git config user.name "github actions"
  git status
  git checkout "${branch}"
  git commit -am "doc: update er diagram"
  git push origin "${branch}"

  gh pr create \
    --base master \
    --title "Update er diagram" \
    --body "Created by scheduled workflow" \
    --reviewer 'ymgyt'
}

function main() {
  parse_args ${@+"$@"}
  check_commands

  structiagram --dir "${SRC_DIR}" --output "${NEW_MD}"

  if  diff "${ORG_MD}" "${NEW_MD}" &> /dev/null; then
    echo "no diff was found"
  else
    echo "diff detected"
    mv "${NEW_MD}" "${ORG_MD}"
    generate_diagram
    if [ "${GIT_PUSH}" == "YES" ]; then
      git_push
    fi
  fi
}

main ${@+"$@"}
