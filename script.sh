#!/bin/bash

# FOR TESTING ONLY

OUTPUT_FILE="domains.txt"
TEMP_DIR=$(mktemp -d)

TEXT_URLS=(
    "https://disposable.github.io/disposable-email-domains/domains.txt"
    "https://raw.githubusercontent.com/disposable-email-domains/disposable-email-domains/main/disposable_email_blocklist.conf"
    "https://raw.githubusercontent.com/7c/fakefilter/main/txt/data.txt"
    "https://raw.githubusercontent.com/wesbos/burner-email-providers/master/emails.txt"
)

echo "Fetching text lists..."
for url in "${TEXT_URLS[@]}"; do
    curl -sL "$url" | grep -v '^#' >> "$TEMP_DIR/raw_list.txt"
done

JSON_URLS=(
    "https://raw.githubusercontent.com/Propaganistas/Laravel-Disposable-Email/refs/heads/master/domains.json"
    "https://deviceandbrowserinfo.com/api/emails/disposable"
)

echo "Fetching JSON lists..."
for url in "${JSON_URLS[@]}"; do
    curl -sL "$url" | jq -r '.[]' 2>/dev/null >> "$TEMP_DIR/raw_list.txt"
done

echo "Cleaning and sorting..."
tr -d '\r' < "$TEMP_DIR/raw_list.txt" | \
grep -Ei '^[a-z0-9].*\.' | \
sort -u | \
sed '/^\s*$/d' > "$OUTPUT_FILE"

rm -rf "$TEMP_DIR"

echo "------------------------------------------"
echo "Update complete!"
echo "Total unique domains: $(wc -l < "$OUTPUT_FILE")"
echo "Saved to: $OUTPUT_FILE"
