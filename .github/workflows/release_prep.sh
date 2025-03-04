#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}

# The prefix is chosen to match what GitHub generates for source archives
# This guarantees that users can easily switch from a released artifact to a source archive
# with minimal differences in their code (e.g. strip_prefix remains the same)
PREFIX="fixture-multi-module-root-${TAG:1}"
ARCHIVE="${ARTIFACTS_DIR}/fixture-multi-module-root-$TAG.tar.gz"
ARCHIVE_TMP=$(mktemp)

# NB: configuration for 'git archive' is in /.gitattributes
git archive --format=tar --prefix=${PREFIX}/ ${TAG} >$ARCHIVE_TMP
gzip <$ARCHIVE_TMP >$ARCHIVE

PREFIX="fixture-multi-module-sub-${TAG:1}"
ARCHIVE="${ARTIFACTS_DIR}/fixture-multi-module-sub-$TAG.tar.gz"
ARCHIVE_TMP=$(mktemp)

# NB: configuration for 'git archive' is in /.gitattributes
git archive --format=tar --prefix=${PREFIX}/ ${TAG} sub/module >$ARCHIVE_TMP
gzip <$ARCHIVE_TMP >$ARCHIVE

cat <<EOF > $RELEASE_NOTES

## Release notes

Foobar

\`\`\`

EOF

jq --null-input \
  --arg archive1 "${ARTIFACTS_DIR}/fixture-multi-module-root-$TAG.tar.gz" \
  --arg archive2 "${ARTIFACTS_DIR}/fixture-multi-module-sub-$TAG.tar.gz" \
  '{release_archives: [$archive1, $archive2]}'