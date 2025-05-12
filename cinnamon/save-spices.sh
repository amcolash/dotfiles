#!/usr/bin/env bash

echo "Saving installed Cinnamon spices..."

ls ~/.local/share/cinnamon/applets    > "applets.txt"
ls ~/.local/share/cinnamon/extensions > "extensions.txt"
