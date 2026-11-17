#!/usr/bin/env bash
# Build Debian packages of this fork on the machine you run it on, using upstream's
# packaging/ files (the same steps as docker/Taskfile.yaml, without Docker or Go Task).
#
#   vrf/packaging/build-debs.sh [revision]      (default: vrf/main)
#
# The revision is exported with git archive, so uncommitted changes are never packaged.
# Packages land in output/vrf-<codename>-<arch>/. The version is
# <upstream>+vrf<commit date>.<time>~<codename>1, which sorts above Wavelet Lab's PPA
# build of the same release (<upstream>~<codename>0), and the maintainer is this
# checkout's git identity.
#
# Build dependencies on Ubuntu 26.04:
#   sudo apt install build-essential cmake python3-yaml dwarves libusb-1.0-0-dev check \
#       libsoapysdr-dev debhelper dh-dkms dkms

set -euo pipefail

revision=${1:-vrf/main}
repo=$(git rev-parse --show-toplevel)
cd "$repo"

commit=$(git rev-parse --short=7 "$revision^{commit}")
. /etc/os-release
codename=${VERSION_CODENAME:?}
distro_dir="${ID}-${codename}"
arch=$(dpkg --print-architecture)

if [[ ! -d "packaging/$distro_dir" ]]; then
    echo "No packaging/$distro_dir in this checkout." >&2
    exit 1
fi

maintainer_name=$(git config user.name)
maintainer_email=$(git config user.email)
upstream_version=$(git show "$revision:src/Changelog.txt" |
    sed -n 's/^Release \([^ ]*\) (.*)$/\1/p' | head -n 1)
stamp=$(git log -1 --format=%cd --date=format-local:%Y%m%d.%H%M "$revision")
version="${upstream_version}+vrf${stamp}~${codename}1"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
source_dir="$work/usdr-$version"
mkdir -p "$source_dir"
git archive "$revision" src LICENSE README.md packaging | tar -x -C "$source_dir"

cd "$source_dir"
cat > packaging/package-metadata <<EOF
PACKAGE_MAINTAINER_NAME='$maintainer_name'
PACKAGE_MAINTAINER_EMAIL='$maintainer_email'
DEBIAN_STANDARDS_VERSION='4.6.2'
EOF
ln -s "packaging/$distro_dir" debian
cp LICENSE debian/copyright
packaging/generate-debian-control.sh "$distro_dir" debian/control
packaging/generate-debian-changelog.sh src/Changelog.txt "$codename" "$codename" \
    "$work/upstream.changelog"

{
    printf 'usdr (%s) %s; urgency=medium\n\n' "$version" "$codename"
    printf '  * Valentine RF build of %s (%s) from github.com/cvalentine99/usdr-lib.\n' \
        "$revision" "$commit"
    git -C "$repo" log --format='  * %s' "origin/main..$revision" -- src
    printf '\n -- %s <%s>  %s\n\n' "$maintainer_name" "$maintainer_email" \
        "$(date --rfc-email)"
    cat "$work/upstream.changelog"
} > debian/changelog

dpkg-checkbuilddeps
dpkg-buildpackage -us -uc -b -j"$(nproc)"

out="$repo/output/vrf-$codename-$arch"
mkdir -p "$out"
cp "$work"/*.deb "$out"/
echo
echo "Packages for usdr $version ($commit):"
ls -1 "$out"/*"$version"*.deb
