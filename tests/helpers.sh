#!/usr/bin/env bash

# Mock curl function to simulate Coda API responses
mock_coda_api() {
  local method="$3"
  local url="$4"

  # Extract the endpoint by removing the base URL
  local endpoint="${url#"$BASE_URL/"}"

  # Handle POST, DELETE, PUT requests
  if [ "$method" == "POST" ] || [ "$method" == "DELETE" ] || [ "$method" == "PUT" ]; then
    echo '{"status":"OK"}'
    return
  fi

  echo "GET $endpoint" >&2

  # Handle GET requests and mock based on the extracted endpoint
  case "$endpoint" in
  "docs")
    echo '{"items":[{"id":"doc-123","name":"My Document"}]}'
    ;;
  "docs/$DOC_ID")
    echo '{"id":"doc-123","name":"My Document"}'
    ;;
  "docs/$DOC_ID/tables")
    echo '{"items":[{"id":"tbl-456","name":"My Table"}]}'
    ;;
  "docs/$DOC_ID/tables/$TABLE_ID")
    echo '{"id":"tbl-456","name":"My Table"}'
    ;;
  "docs/$DOC_ID/tables/$TABLE_ID/rows/row-1")
    echo '{"values":{"col-1":"value1","col-2":"value2"}}'
    ;;
  "docs/$DOC_ID/pages")
    echo '{"items":[{"id":"page-789","name":"My Page"}]}'
    ;;
  "docs/$DOC_ID/pages/$PAGE_ID")
    echo '{"id":"page-789","name":"My Page"}'
    ;;
  "docs/$DOC_ID/acl/permissions")
    echo '{"items":[{"id":"perm-001","principal":{"email":"user@example.com"},"access":"read"}]}'
    ;;
  "categories")
    echo '{"items":[{"id":"cat-001","name":"Category 1"}]}'
    ;;
  *)
    echo '{"status":"OK"}'
    ;;
  esac
}

export -f mock_coda_api
