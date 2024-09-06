#!/bin/bash

# Coda API base URL and API key
BASE_URL="https://coda.io/apis/v1"

: "${CODA_API_KEY?CODA_API_KEY must be set}"

# Common curl utility function (1-liner version)
# $1 = HTTP method, $2 = endpoint, $3 = optional data (JSON for POST/PUT)
curl_request() {
  curl -s -X "$1" "$BASE_URL/$2" \
    -H "Authorization: Bearer $CODA_API_KEY" \
    -H "Content-Type: application/json" \
    "$([ "$1" = "POST" ] || [ "$1" = "PUT" ] && echo "-d '$3'")"
}

# GET request: $1 = endpoint
get() { curl_request "GET" "$1"; }

# POST request: $1 = endpoint, $2 = data (JSON)
post() { curl_request "POST" "$1" "$2"; }

# PUT request: $1 = endpoint, $2 = data (JSON)
put() { curl_request "PUT" "$1" "$2"; }

# DELETE request: $1 = endpoint
delete() { curl_request "DELETE" "$1"; }

### Documents ###
list_docs() { get "docs"; }
create_doc() { post "docs" "{\"title\":\"$1\"}"; }
get_doc_info() { get "docs/$1"; }
delete_doc() { delete "docs/$1"; }
update_doc() { put "docs/$1" "{\"title\":\"$2\"}"; }

### Tables ###
list_tables() { get "docs/$1/tables"; }
get_table_info() { get "docs/$1/tables/$2"; }
insert_rows() { post "docs/$1/tables/$2/rows" "$3"; }
delete_rows() { post "docs/$1/tables/$2/rows/delete" "{\"rowIds\":[$3]}"; }
push_button() { post "docs/$1/tables/$2/rows/$3/buttons/$4" "{}"; }

### Rows ###
get_row() { get "docs/$1/tables/$2/rows/$3"; }
update_row() { put "docs/$1/tables/$2/rows/$3" "$4"; }
delete_row() { delete "docs/$1/tables/$2/rows/$3"; }

### Pages ###
list_pages() { get "docs/$1/pages"; }
get_page_info() { get "docs/$1/pages/$2"; }
begin_content_export() { post "docs/$1/pages/$2/export" "{\"outputFormat\":\"$3\"}"; }
update_page() { put "docs/$1/pages/$2" "{\"name\":\"$3\"}"; }
delete_page() { delete "docs/$1/pages/$2"; }

### Permissions ###
list_permissions() { get "docs/$1/acl/permissions"; }
add_permission() { post "docs/$1/acl/permissions" "{\"access\":\"$3\",\"principal\":{\"type\":\"email\",\"email\":\"$2\"}}"; }
remove_permission() { delete "docs/$1/acl/permissions/$2"; }

### Miscellaneous ###
list_categories() { get "categories"; }
