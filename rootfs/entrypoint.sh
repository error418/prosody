#!/bin/sh

set -e

if [ "$1" = "prosody" ]; then
    if /usr/bin/find "/entrypoint.d/" -mindepth 1 -maxdepth 1 -type f -print -quit 2>/dev/null | read v; then
        find "/entrypoint.d/" -follow -type f -print | sort -V | while read -r f; do
            case "$f" in
                *.sh)
                    if [ -x "$f" ]; then
                        echo "Launching $f";
                        "$f"
                    else
                        # warn on shell scripts without exec bit
                        echo "Ignoring $f, not executable";
                    fi
                    ;;
                *) echo "Ignoring $f";;
            esac
        done
    else
        echo "No files found in /entrypoint.d/, skipping configuration"
    fi
fi

exec "$@"
