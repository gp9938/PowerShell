echo "Starting git daemon"
git daemon --verbose --reuseaddr --base-path=d:\git-config-repos d:\git-config-repos --export-all --enable=receive-pack

Start-Sleep 7500