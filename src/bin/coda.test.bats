#!/usr/bin/env bats

# Load BATS support and assert libraries
setup() {
  bats_load_library bats-support
  bats_load_library bats-assert

  load ${BATS_CWD}/tests/helpers.sh

  CODA_API_KEY="mock_api_key"

  export DOC_ID="doc-123"
  export TABLE_ID="tbl-456"
  export PAGE_ID="page-789"

  curl() { mock_coda_api "$@"; }
  export -f curl

  BIN="./src/bin/coda.sh"
}

# Tests

@test "list docs" {
  run $BIN docs list
  assert_success
  assert_output --partial '"id":"doc-123"'
}

@test "create doc" {
  run $BIN docs create "New Document"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "get doc info" {
  run $BIN docs info "$DOC_ID"
  assert_success
  assert_output --partial '"id":"doc-123"'
}

@test "delete doc" {
  run $BIN docs delete "$DOC_ID"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "update doc" {
  run $BIN docs update "$DOC_ID" "Updated Title"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "list tables" {
  run $BIN tables list "$DOC_ID"
  assert_success
  assert_output --partial '"id":"tbl-456"'
}

@test "get table info" {
  run $BIN tables info "$DOC_ID" "$TABLE_ID"
  assert_success
  assert_output --partial '"id":"tbl-456"'
}

@test "insert rows" {
  run $BIN rows insert "$DOC_ID" "$TABLE_ID" '[{"column":"col-1","value":"val1"},{"column":"col-2","value":"val2"}]'
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "upsert rows" {
  run $BIN rows upsert "$DOC_ID" "$TABLE_ID" '[{"column":"col-1","value":"newval1"},{"column":"col-2","value":"newval2"}]'
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "get row info" {
  run $BIN rows get "$DOC_ID" "$TABLE_ID" "row-1"
  assert_success
  assert_output --partial '"col-1":"value1"'
}

@test "update row" {
  run $BIN rows update "$DOC_ID" "$TABLE_ID" "row-1" '{"cells":[{"column":"col-1","value":"new_value"}]}'
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "delete row" {
  run $BIN rows delete "$DOC_ID" "$TABLE_ID" "row-1"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "list pages" {
  run $BIN pages list "$DOC_ID"
  assert_success
  assert_output --partial '"id":"page-789"'
}

@test "get page info" {
  run $BIN pages info "$DOC_ID" "$PAGE_ID"
  assert_success
  assert_output --partial '"id":"page-789"'
}

@test "list permissions" {
  run $BIN permissions list "$DOC_ID"
  assert_success
  assert_output --partial '"email":"user@example.com"'
}

@test "add permission" {
  run $BIN permissions add "$DOC_ID" "user@example.com" "read"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "remove permission" {
  run $BIN permissions remove "$DOC_ID" "perm-001"
  assert_success
  assert_output --partial '{"status":"OK"}'
}

@test "list categories" {
  run $BIN categories list
  assert_success
  assert_output --partial '"id":"cat-001"'
}
