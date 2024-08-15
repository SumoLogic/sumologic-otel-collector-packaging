#!/bin/bash
set -m

# shellcheck disable=SC1083
%selinux_modules_install -s %{selinuxtype} -p 200 %{_datadir}/selinux/packages/%{modulename}.pp.bz2 &> /dev/null
