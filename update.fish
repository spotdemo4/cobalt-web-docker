#! /usr/bin/env nix-shell
#! nix-shell -i fish -p fish jq skopeo

echo ""

set registry ghcr.io/spotdemo4/cobalt-web

set cobalt_version (
    curl -s https://raw.githubusercontent.com/imputnet/cobalt/refs/heads/main/web/package.json | jq -r '.version'
)
if test -z "$cobalt_version"
    echo "failed to fetch the latest version"
    return 1
end
echo "latest cobalt web version: $cobalt_version"

set tags (
    skopeo list-tags --creds trev:$token docker://$registry | jq -r '.Tags[]'
)
if test -z "$tags"
    echo "failed to fetch existing tags from ghcr.io"
    return 1
end
echo "current tags: $tags"

for tag in $tags
    if string match -q "$cobalt_version" $tag
        echo "tag $tag already exists, skipping update"
        return 0
    end
end

echo "tag $cobalt_version does not exist, proceeding with update"

echo "logging into ghcr.io"
echo "$token" | docker login ghcr.io --username trev --password-stdin

echo "creating amd64 image"
docker build --platform linux/amd64 -t $registry:$cobalt_version-amd64 .
docker push $registry:$cobalt_version-amd64

echo "creating arm64 image"
docker build --platform linux/arm64 -t $registry:$cobalt_version-arm64 .
docker push $registry:$cobalt_version-arm64

echo "creating multi-arch manifest"
docker manifest create $registry:$cobalt_version --amend $registry:$cobalt_version-amd64 --amend $registry:$cobalt_version-arm64
docker manifest annotate $registry:$cobalt_version $registry:$cobalt_version-amd64 --arch amd64
docker manifest annotate $registry:$cobalt_version $registry:$cobalt_version-arm64 --arch arm64
docker manifest push $registry:$cobalt_version

echo "creating multi-arch manifest with latest tag"
docker manifest create $registry:latest --amend $registry:$cobalt_version-amd64 --amend $registry:$cobalt_version-arm64
docker manifest annotate $registry:latest $registry:$cobalt_version-amd64 --arch amd64
docker manifest annotate $registry:latest $registry:$cobalt_version-arm64 --arch arm64
docker manifest push --purge $registry:latest