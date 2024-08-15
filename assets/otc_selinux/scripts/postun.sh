#!/bin/sh
set -m

if [ "$1" -eq 0 ]; then
    # shellcheck disable=SC1083
    %selinux_modules_uninstall -s %{selinuxtype} -p 200 %{modulename}
fi
