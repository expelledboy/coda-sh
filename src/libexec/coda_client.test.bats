#!/usr/bin/env bats

# Load BATS support and assert libraries
setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  load ${BATS_CWD}/tests/helpers.sh

  CODA_API_KEY="mock_api_key"

  DOC_ID="doc-123"
  TABLE_ID="tbl-456"
  PAGE_ID="page-789"

  curl() { mock_coda_api "$@"; }
  export -f curl

  source ./src/libexec/coda_client.sh
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
