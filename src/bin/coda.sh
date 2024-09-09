#!/bin/bash

# Source the Coda Bash client
source "${LIBEXEC_PATH}/coda_client.sh"

# Default values
FORMAT="json"
INPUT_FORMAT="json"

# Function to print usage instructions
usage() {
  SCRIPT=$(basename "$0")

  cat <<EOF
Usage: $SCRIPT [OPTIONS] <command> [sub-command] [args]

Commands and Sub-Commands:
  docs
    list                           List all documents
    info <doc_id>                  Get information about a specific document
    create <title>                 Create a new document with a given title
    delete <doc_id>                Delete a document by its ID
    update <doc_id> <new_title>    Update a document's title

  tables
    list <doc_id>                  List all tables in a document
    info <doc_id> <table_id>        Get information about a specific table

  rows
    get <doc_id> <table_id> <row_id>                Get information about a specific row
    update <doc_id> <table_id> <row_id> <json_data> Update a row with JSON data
    insert <doc_id> <table_id> <rows_json|csv>      Insert rows (JSON or CSV format)
    upsert <doc_id> <table_id> <rows_json|csv>      Upsert rows (JSON or CSV format)
    delete <doc_id> <table_id> <row_id>             Delete a specific row by its ID

  pages
    list <doc_id>                   List all pages in a document
    info <doc_id> <page_id>         Get information about a specific page

  permissions
    list <doc_id>                   List all permissions for a document
    add <doc_id> <email> <access>   Add permission for a user by email with access level
    remove <doc_id> <perm_id>       Remove a permission by its ID

  categories
    list                            List all categories

Options:
  -f, --format <json|csv>            Set output format (default: json)
  -i, --input-format <json|csv>      Set input format (default: json for data input commands like insert/upsert rows)
  -h, --help                         Show this help message

Examples:
  $SCRIPT docs list                                                 # List all documents
  $SCRIPT docs create "My New Document"                             # Create a new document
EOF
  exit 1
}

# Convert CSV to JSON for row insertion/upsertion
csv_to_json_rows() {
  echo "$1" | jq -R 'split("\n") | map(split(",")) | map({ "cells": map({ "column": .[0], "value": .[1] }) }) | { rows: . }'
}

# Convert CSV to JSON using jq templates (input)
csv_to_json() {
  case "$1" in
  rows)
    csv_to_json_rows "$2"
    ;;
  docs)
    echo "$2" | jq -R 'split(",") | { "title": .[0] }'
    ;;
  *)
    echo "$2"
    ;;
  esac
}

# Convert JSON to CSV using jq templates (output)
convert_to_csv() {
  case "$1" in
  docs) jq -r '.items[] | [.id, .name] | @csv' ;;
  tables) jq -r '.items[] | [.id, .name] | @csv' ;;
  rows) jq -r '.items[] | [.id, .values] | @csv' ;;
  pages) jq -r '.items[] | [.id, .name] | @csv' ;;
  permissions) jq -r '.items[] | [.id, .principal.email, .access] | @csv' ;;
  *) jq -r ;;
  esac
}

# Parse options using getopts
while [[ $# -gt 0 ]]; do
  case "$1" in
  -f | --format)
    FORMAT="$2"
    shift 2
    ;;
  -i | --input-format)
    INPUT_FORMAT="$2"
    shift 2
    ;;
  -h | --help)
    usage
    ;;
  -*)
    echo "Unknown option: $1"
    usage
    ;;
  *)
    break
    ;;
  esac
done

# Ensure command is provided
COMMAND="$1"
[ -z "$COMMAND" ] && usage
shift

# Prepare the input if the input format is CSV
prepare_input() {
  if [[ "$INPUT_FORMAT" == "csv" ]]; then
    csv_to_json "$COMMAND" "$1"
  else
    echo "$1"
  fi
}

# Execute the appropriate function based on the command
case "$COMMAND" in
docs)
  case "$1" in
  list) output=$(list_docs) ;;
  info) output=$(get_doc_info "$2") ;;
  create) output=$(create_doc "$(prepare_input "$2")") ;;
  delete) output=$(delete_doc "$2") ;;
  update) output=$(update_doc "$2" "$(prepare_input "$3")") ;;
  *) usage ;;
  esac
  ;;

tables)
  case "$1" in
  list) output=$(list_tables "$2") ;;
  info) output=$(get_table_info "$2" "$3") ;;
  *) usage ;;
  esac
  ;;

rows)
  case "$1" in
  get) output=$(get_row "$2" "$3" "$4") ;;
  update) output=$(update_row "$2" "$3" "$4" "$(prepare_input "$5")") ;;
  insert) output=$(insert_rows "$2" "$3" "$(prepare_input "$3")") ;;
  upsert) output=$(upsert_rows "$2" "$3" "$(prepare_input "$3")") ;;
  delete) output=$(delete_row "$2" "$3" "$4") ;;
  *) usage ;;
  esac
  ;;

pages)
  case "$1" in
  list) output=$(list_pages "$2") ;;
  info) output=$(get_page_info "$2" "$3") ;;
  *) usage ;;
  esac
  ;;

permissions)
  case "$1" in
  list) output=$(list_permissions "$2") ;;
  add) output=$(add_permission "$2" "$3" "$4") ;;
  remove) output=$(remove_permission "$2" "$3") ;;
  *) usage ;;
  esac
  ;;

categories)
  case "$1" in
  list) output=$(list_categories) ;;
  *) usage ;;
  esac
  ;;

*)
  usage
  ;;
esac

# Output the result in the desired format
if [[ "$FORMAT" == "csv" ]]; then
  echo "$output" | convert_to_csv "$COMMAND"
else
  echo "$output" | jq -c
fi
