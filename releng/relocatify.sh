#!/bin/bash

package=$1
prefix=$2
sdk=$3
[ -z "$package" -o -z "$prefix" -o -z "$sdk" ] && exit 1

build_platform=$(uname -s | tr '[A-Z]' '[a-z]' | sed 's,^darwin$,mac,')

shopt -s expand_aliases
if [ "$build_platform" = "mac" ]; then
  alias sed_inplace='sed -i ""'
else
  alias sed_inplace='sed -i'
fi

for file in $(find "$package" -type f); do
  if grep -q "$prefix" $file; then
    if echo "$file" | grep -Eq "\\.pm$|aclocal.*|autoconf|autoheader|autom4te.*|automake.*|autoreconf|autoscan|autoupdate|gdbus-codegen|/glib-2.0/codegen/|glib-gettextize|/gdb/auto-load/|ifnames|libtoolize"; then
      newname="$file.frida.in"
      mv "$file" "$newname"
      sed_inplace \
        -e "s,$prefix,@FRIDA_TOOLROOT@,g" \
        $newname
    elif echo "$file" | grep -Eq "\\.la$"; then
      newname="$file.frida.in"
      mv "$file" "$newname"
      sed_inplace \
        -e "s,$prefix,@FRIDA_SDKROOT@,g" \
        -e "s,-L$sdk/lib ,,g" \
        $newname
    elif echo "$file" | grep -Eq "\\.pc$"; then
      sed_inplace \
        -e "s,$prefix,\${frida_sdk_prefix},g" \
        $file
    fi
  fi
done
