echo "Starting git daemon"
git daemon --reuseaddr --base-path=d:\git-config-repos d:\git-config-repos --export-all --enable=receive-pack
