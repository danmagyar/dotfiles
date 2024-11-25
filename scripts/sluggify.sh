#!/bin/bash
set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 <string>"
    echo "Example: $0 'Hello World!' -> hello-world"
    exit 1
fi


echo "$1" | tr '\n' ' ' | sed -E '
    s/ITD-/FIRSTJIRAID-/;
    s/ITD-/\/ITD-/g;
    s/FIRSTJIRAID-/ITD-/;
    s/ /-/g;
    s/-?\/-?/\//g;
    s/[^a-zA-Z0-9/._-]+//g;
    s/\.\.+/\./g;
    s/^(\.+|\/+|-+)//;
    s/(\.+|\/+|-+)$//;
    s/\/{2,}/\//g;
    s/\.\.//g;
    s/-{2,}/-/g;
' | awk '{print $0"\n"}'

