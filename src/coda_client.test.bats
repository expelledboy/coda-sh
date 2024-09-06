#!/usr/bin/env bats

# Mock curl function to simulate Coda API responses
curl() {
  local method="$3"
  local url="$4"

  # Extract the endpoint by removing the base URL
  local endpoint="${url#"$BASE_URL/"}"

  if [ "$method" == "POST" ] || [ "$method" == "DELETE" ] || [ "$method" == "PUT" ]; then
    echo '{"status":"OK"}'
    return
  fi

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

# Load BATS support and assert libraries
setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  export CODA_API_KEY="mock_api_key"

  export DOC_ID="doc-123"
  export TABLE_ID="tbl-456"
  export PAGE_ID="page-789"

  export -f curl

  source ./src/coda_client.sh
}

# Tests
@test "list docs" {
  run list_docs
  assert_success
  assert_output --partial '"id":"doc-123"'
}

@test "create doc" {
  run create_doc "New Document"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "get doc info" {
  run get_doc_info "$DOC_ID"
  assert_success
  assert_output --partial '"id":"doc-123"'
}

@test "delete doc" {
  run delete_doc "$DOC_ID"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "update doc" {
  run update_doc "$DOC_ID" "Updated Document"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "list tables" {
  run list_tables "$DOC_ID"
  assert_success
  assert_output --partial '"id":"tbl-456"'
}

@test "get table info" {
  run get_table_info "$DOC_ID" "$TABLE_ID"
  assert_success
  assert_output --partial '"id":"tbl-456"'
}

@test "insert rows" {
  run insert_rows "$DOC_ID" "$TABLE_ID" '{"rows":[{"cells":[{"column":"col-1","value":"data1"}]}]}'
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "delete rows" {
  run delete_rows "$DOC_ID" "$TABLE_ID" '["row-1"]'
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "push button on row" {
  run push_button "$DOC_ID" "$TABLE_ID" "row-1" "btn-123"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "get row" {
  run get_row "$DOC_ID" "$TABLE_ID" "row-1"
  assert_success
  assert_output --partial '"col-1":"value1"'
}

@test "update row" {
  run update_row "$DOC_ID" "$TABLE_ID" "row-1" '{"cells":[{"column":"col-1","value":"new_value"}]}'
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "delete row" {
  run delete_row "$DOC_ID" "$TABLE_ID" "row-1"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "list pages" {
  run list_pages "$DOC_ID"
  assert_success
  assert_output --partial '"id":"page-789"'
}

@test "get page info" {
  run get_page_info "$DOC_ID" "$PAGE_ID"
  assert_success
  assert_output --partial '"id":"page-789"'
}

@test "begin content export" {
  run begin_content_export "$DOC_ID" "$PAGE_ID" "html"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "update page" {
  run update_page "$DOC_ID" "$PAGE_ID" "Updated Page"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "delete page" {
  run delete_page "$DOC_ID" "$PAGE_ID"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "list permissions" {
  run list_permissions "$DOC_ID"
  assert_success
  assert_output --partial '"email":"user@example.com"'
}

@test "add permission" {
  run add_permission "$DOC_ID" "user@example.com" "read"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "remove permission" {
  run remove_permission "$DOC_ID" "perm-001"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "list categories" {
  run list_categories
  assert_success
  assert_output --partial '"id":"cat-001"'
}
