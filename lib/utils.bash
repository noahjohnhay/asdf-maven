#!/usr/bin/env bash

# Shared helpers for bin/list-all and bin/latest-stable.
#
# When ASDF_MAVEN_MIRROR is set, versions are read from the mirror's directory
# listings (the same tree bin/install downloads from) and apache.org is never
# contacted. Otherwise they are scraped from the Maven release history page.

MAVEN_HISTORY_URL="https://maven.apache.org/docs/history.html"
MAVEN_SNAPSHOT_METADATA_URL="https://repository.apache.org/content/repositories/snapshots/org/apache/maven/apache-maven/maven-metadata.xml"

# Majors laid out as maven-<major>/<version>/binaries/ in the dist tree.
MAVEN_MIRROR_MAJORS="2 3 4"

# Keep every request well inside mise's 20s list-all timeout.
CURL_OPTS=(-fsSL --connect-timeout 5 --max-time 15)

# Directory entries that look like versions, e.g. href="3.9.12/".
list_mirror_versions() {
	local base="${ASDF_MAVEN_MIRROR%/}"
	local tmp
	tmp="$(mktemp -d)"

	local major
	local pids=()
	for major in $MAVEN_MIRROR_MAJORS; do
		curl "${CURL_OPTS[@]}" -o "$tmp/$major.html" "$base/maven-$major/" 2>"$tmp/$major.err" &
		pids+=($!)
	done

	local failed=0
	local pid
	for pid in "${pids[@]}"; do
		wait "$pid" || failed=1
	done
	if [[ $failed -ne 0 ]]; then
		cat "$tmp"/*.err >&2
		rm -rf "$tmp"
		echo "asdf-maven: could not list versions from $base (ASDF_MAVEN_MIRROR)" >&2
		return 1
	fi

	cat "$tmp"/*.html | grep -oE 'href="[0-9][^"/]*/"' | sed -E 's/^href="(.*)\/"$/\1/'
	rm -rf "$tmp"
}

list_apache_versions() {
	local html
	html="$(curl "${CURL_OPTS[@]}" "$MAVEN_HISTORY_URL")" || {
		echo "asdf-maven: could not fetch $MAVEN_HISTORY_URL" >&2
		return 1
	}
	echo "$html" | sed -nE 's/.*<td>(<b>)?([0-9]+\.[0-9]+(\.[0-9]+)?(-[0-9a-zA-Z-]*)?)(<\/b>)?<\/td>.*/\2/p'

	# Snapshots are best effort; a failure here must not hide the releases.
	curl "${CURL_OPTS[@]}" "$MAVEN_SNAPSHOT_METADATA_URL" 2>/dev/null |
		grep -oE '<version>[0-9][^<]*-SNAPSHOT</version>' | sed -E 's/<\/?version>//g' || true
}

list_maven_versions() {
	local versions
	if [[ -n "${ASDF_MAVEN_MIRROR:-}" ]]; then
		versions="$(list_mirror_versions)" || return 1
	else
		versions="$(list_apache_versions)" || return 1
	fi
	echo "$versions" | sed '/^$/d' | sort -uV
}
