#!/bin/bash
set -m

# shellcheck disable=SC1083
%selinux_relabel_pre -s %{selinuxtype}
