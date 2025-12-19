#!/usr/bin/env bash

sudo apt-get -y install skopeo

cobalt_version=$(curl -s https://raw.githubusercontent.com/imputnet/cobalt/refs/heads/main/web/package.json | jq -r '.version')
if [[ -z "$cobalt_version" ]]; then
    echo "failed to fetch the latest version"
    return 1
fi
echo "latest cobalt web version: $cobalt_version"

if [[ "${force:-}" = "true" ]]; then
    echo "force update enabled, proceeding with update"
else
    readarray -t tags < <(skopeo list-tags --creds "trev:${token:-}" "docker://${registry:-}" | jq -r '.Tags[]')
    if [[ ${#tags[@]} -eq 0 ]]; then
        echo "failed to fetch existing tags from ghcr.io"
        return 1
    fi
    echo "current tags: ${tags[*]}"

    for tag in "${tags[@]}"; do
        if [[ "$cobalt_version" == "$tag" ]]; then
            echo "tag $tag already exists, skipping update"
            return 0
        fi
    done

    echo "tag $cobalt_version does not exist, proceeding with update"
fi

echo "version=$cobalt_version" > "$GITHUB_OUTPUT"
