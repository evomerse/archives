#!/bin/sh
set -e

: "${BASIC_AUTH_USER:?La variable d'environnement BASIC_AUTH_USER est requise}"
: "${BASIC_AUTH_PASSWORD:?La variable d'environnement BASIC_AUTH_PASSWORD est requise}"

htpasswd -cb /usr/local/apache2/conf/.htpasswd "$BASIC_AUTH_USER" "$BASIC_AUTH_PASSWORD"

NOTES_DIR=/usr/local/apache2/htdocs/notes

render_dir() {
	dir=$1
	indent=$2

	find "$dir" -maxdepth 1 -type f -name "*.md" ! -name "_sidebar.md" ! -name "README.md" 2>/dev/null | sort | while IFS= read -r f; do
		rel=${f#"$NOTES_DIR"/}
		name=$(basename "$f" .md)
		name=$(printf '%s' "$name" | tr '_' ' ')
		echo "${indent}- [${name}](${rel})"
	done

	find "$dir" -mindepth 1 -maxdepth 1 -type d ! -name ".*" 2>/dev/null | sort | while IFS= read -r d; do
		if find "$d" -type f -name "*.md" 2>/dev/null | grep -q .; then
			dname=$(basename "$d")
			dname=$(printf '%s' "$dname" | tr '_' ' ')
			echo "${indent}- ${dname}"
			render_dir "$d" "  $indent"
		fi
	done
}

generate_sidebar() {
	{
		echo "- [Accueil](/)"
		render_dir "$NOTES_DIR" ""
	} > "$NOTES_DIR/_sidebar.md.tmp" && mv "$NOTES_DIR/_sidebar.md.tmp" "$NOTES_DIR/_sidebar.md"
}

(
	while true; do
		generate_sidebar || true
		sleep 15
	done
) &

exec "$@"
