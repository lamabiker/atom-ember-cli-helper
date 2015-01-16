# Script to capture possible generators
# Perl code courtesy of Joel Roggeman <https://github.com/jroggeman>

ember generate --help | perl -n -e'/ {6}([a-zA-Z-]+) <name>/ && print $1 . "\n"'
