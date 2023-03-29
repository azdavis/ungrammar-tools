#!/bin/sh

set -eu

if [ "$#" -ne 0 ]; then
  echo "usage: $0"
  exit 1
fi

cd "$(dirname "$0")"
cd ..

echo 'installing deps'
sudo apt-get update
sudo apt-get install jq

echo 'checking package json version is same as github ref version'
pj="v$(jq -r '.version' editors/vscode/package.json)"
if [ "$GITHUB_REF_NAME" != "$pj" ]; then
  echo 'mismatch'
  echo "  github ref:   $GITHUB_REF_NAME"
  echo "  package json: $pj"
  exit 1
fi

echo 'copying license'
cp LICENSE.md editors/vscode

echo 'entering vscode dir'
cd editors/vscode

echo 'installing node deps'
npm ci

echo 'building vsix'
npx --no-install vsce package

echo 'publishing to vs code marketplace'
npx --no-install vsce publish --pat "$AZURE_MARKETPLACE_TOKEN" --packagePath *.vsix

echo 'publishing to open vsx'
npx --no-install ovsx publish --pat "$OPEN_VSX_TOKEN" --packagePath *.vsix

echo 'ok'
