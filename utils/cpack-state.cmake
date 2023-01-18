#
# This is based on: https://github.com/preed/cmake-thirdparty-manager/
#
# Copyright (c) 2017 Threat Stack, Inc. All Rights Reserved
#                    J. Paul Reed
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# These are macros/functions we need to do various things.
#
# The two functions below allow us to safely include the CPack module multiple
# times without receiving the "multiple inclusion" warning.
#
# While CPack was not designed for this purpose, this allows us to utilize
# CPack to generate 3rdparty package archives inside of this framework without
# tainting or leaking CPack configuration to the rest of the project.
#
# The approach was vetted by the developer who actually wrote that warning:
#
#   https://cmake.org/pipermail/cmake/2017-October/066437.html
#
# The two macros below implement his suggestions.
#

# Reset CPack state
macro(reset_cpack_state)
    foreach(_varName ${_varNames})
        string(TOLOWER ${_varName} _lc_varName)
        string(REGEX MATCH "^cpack_" _cpack_var ${_lc_varName})

        if (_cpack_var)
            message("reset_cpack_state(): unsetting ${_varName}")
            unset(${_varName})
        endif()
    endforeach()
endmacro()
