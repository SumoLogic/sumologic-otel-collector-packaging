#!/bin/bash
set -m

# shellcheck disable=SC1083
%selinux_relabel_post -s %{selinuxtype} &> /dev/null
