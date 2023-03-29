#!/bin/sh

set -eu

if [ "$#" -ne 0 ]; then
  echo "usage: $0"
  exit 1
fi

cd "$(dirname "$0")"
cd ..

header() {
  echo "==> $1"
}

header 'installing deps'
sudo apt-get update
sudo apt-get install jq

header 'entering vscode dir'
cd editors/vscode

header 'copying license'
cp ../../LICENSE.md .

check_version() {
  header "checking github ref version is same as '$1' in $2"
  got="v$(jq -r "$1" "$2")"
  if [ "$GITHUB_REF_NAME" != "$got" ]; then
    echo "mismatch"
    echo "  want: $GITHUB_REF_NAME"
    echo "  got:  $got"
    exit 1
  fi
}

check_version '.version' package.json
check_version '.version' package-lock.json
check_version '.packages."".version' package-lock.json

header 'installing node deps'
npm ci

header 'building vsix'
npx --no-install vsce package

header 'publishing to vs code marketplace'
npx --no-install vsce publish --pat "$AZURE_MARKETPLACE_TOKEN" --packagePath *.vsix

header 'publishing to open vsx'
npx --no-install ovsx publish --pat "$OPEN_VSX_TOKEN" --packagePath *.vsix

header 'ok'
