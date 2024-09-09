# Coda cli and Bash client

A Bash client and cli for interacting with the Coda.

## Requirements

- **Bash** 4+
- **CURL**
- **Coda API Key** from [Coda API Key Page](https://coda.io/account).

## Bash CLI

Install via nix:

```bash
nix profile install expelledboy/coda-sh
```

Usage:

```
$ coda
Usage: coda [OPTIONS] <command> [sub-command] [args]

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
  coda docs list                                                 # List all documents
  coda docs create "My New Document"                             # Create a new document
```


## Bash Client

```bash
cd ~/src/project

git clone git@github.com:expelledboy/coda-sh.git vendor/coda-sh

cat <<EOF > ./main.sh
#!/bin/bash
export CODA_API_KEY="your-coda-api-key"
source vendor/coda-sh/src/libexec/coda_client.sh

# Your code here
list_docs | jq -r '.items[] | .id + " " + .name'
EOF

chmod +x ./main.sh

./main.sh
```

### API Methods

#### Documents
- `list_docs`: List all documents.
- `create_doc <title>`: Create a new document.
- `get_doc_info <doc_id>`: Get info for a specific document.
- `delete_doc <doc_id>`: Delete a document.
- `update_doc <doc_id> <new_title>`: Update a document's title.

#### Tables
- `list_tables <doc_id>`: List tables in a document.
- `get_table_info <doc_id> <table_id>`: Get info for a specific table.
- `insert_rows <doc_id> <table_id> <json_data>`: Insert rows into a table.
- `delete_rows <doc_id> <table_id> <row_ids>`: Delete rows from a table.
- `push_button <doc_id> <table_id> <row_id> <button_id>`: Push a button on a row.

#### Rows
- `get_row <doc_id> <table_id> <row_id>`: Get info for a specific row.
- `update_row <doc_id> <table_id> <row_id> <json_data>`: Update a specific row.
- `delete_row <doc_id> <table_id> <row_id>`: Delete a specific row.

#### Pages
- `list_pages <doc_id>`: List pages in a document.
- `get_page_info <doc_id> <page_id>`: Get info for a specific page.
- `begin_content_export <doc_id> <page_id> <format>`: Export page content.
- `update_page <doc_id> <page_id> <new_name>`: Update a page's name.
- `delete_page <doc_id> <page_id>`: Delete a specific page.

#### Permissions
- `list_permissions <doc_id>`: List permissions for a document.
- `add_permission <doc_id> <email> <access_level>`: Add a permission to a document.
- `remove_permission <doc_id> <permission_id>`: Remove a permission from a document.

#### Miscellaneous
- `list_categories`: List categories.
