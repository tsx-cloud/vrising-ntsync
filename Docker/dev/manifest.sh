docker manifest create --amend tsxcloud/vrising-ntsync:latest \
  tsxcloud/vrising-ntsync:amd64 \
  tsxcloud/vrising-ntsync:arm64

docker manifest push --purge tsxcloud/vrising-ntsync:latest
