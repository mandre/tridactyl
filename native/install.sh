#!/bin/bash

set -e

# To install, curl -fsSl 'url to this script' | bash

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config/tridactyl}"
XDG_DATA_HOME="${XDG_LOCAL_HOME:-$HOME/.local/share/tridactyl}"
manifest_loc="https://raw.githubusercontent.com/cmcaine/tridactyl/master/native/tridactyl.json"
native_loc="https://raw.githubusercontent.com/cmcaine/tridactyl/master/native/native_main.py"

# Decide where to put the manifest based on OS
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    manifest_home="$HOME/.mozilla/native-messaging-hosts/"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    manifest_home="$HOME/Library/Application Support/Mozilla/NativeMessagingHosts/"
fi

mkdir -p "$manifest_home" "$XDG_DATA_HOME"

manifest_file="$manifest_home/tridactyl.json"
native_file="$XDG_DATA_HOME/native_main.py.new"
native_file_final="$XDG_DATA_HOME/native_main.py"

echo "Installing manifest here: $manifest_home"
echo "Installing script here: XDG_DATA_HOME: $XDG_DATA_HOME"

# Until this PR is merged into master, we'll be copying the local version over
# instead of downloading it
if [[ "$1" == "local" ]]; then
    cp -f native/tridactyl.json "$manifest_file"
    cp -f native/native_main.py "$native_file"
else
    curl -sS --create-dirs -o "$manifest_file" "$manifest_loc"
    curl -sS --create-dirs -o "$native_file" "$native_loc"
fi

native_file_escaped=$(sed 's/[&/\]/\\&/g' <<< "$native_file_final")

sed -i.bak "s/REPLACE_ME_WITH_SED/$native_file_escaped/" "$manifest_file"
chmod +x $native_file

# Requirements for native messenger
python_path=$(which python3)
pip_path=$(which pip3)
python_file_escaped=$(sed 's/[&/\]/\\&/g' <<< "$python_path")
if [[ -x "$python_path" ]] && [[ -x "$pip_path" ]]; then
    sed -i.bak "1s/.*/#!$python_file_escaped/" "$native_file"
    mv "$native_file" "$native_file_final"
else
    echo "Error: Python 3 and pip3 must exist in PATH."
    echo "Please install them and run this script again."
    exit 1
fi

echo
echo "Successfully installed Tridactyl native messenger!"
echo "Run ':native' in Firefox to check."
