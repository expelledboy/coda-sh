# Coda Bash Client

A Bash client for interacting with the Coda API.

## Requirements

- **Bash** 4+
- **CURL**
- **Coda API Key** from [Coda API Key Page](https://coda.io/account).

## Getting Started

```bash
cd ~/src/project

git clone git@github.com:expelledboy/coda-sh.git vendor/coda-sh

echo <<EOF >> ~/main.sh
#!/bin/bash
export CODA_API_KEY="your-coda-api-key"
source vendor/coda-sh/src/coda_client.sh
# Your code here
EOF

chmod +x ~/main.sh

~/main.sh
```

## API Methods

### Documents
- `list_docs`: List all documents.
- `create_doc <title>`: Create a new document.
- `get_doc_info <doc_id>`: Get info for a specific document.
- `delete_doc <doc_id>`: Delete a document.
- `update_doc <doc_id> <new_title>`: Update a document's title.

### Tables
- `list_tables <doc_id>`: List tables in a document.
- `get_table_info <doc_id> <table_id>`: Get info for a specific table.
- `insert_rows <doc_id> <table_id> <json_data>`: Insert rows into a table.
- `delete_rows <doc_id> <table_id> <row_ids>`: Delete rows from a table.
- `push_button <doc_id> <table_id> <row_id> <button_id>`: Push a button on a row.

### Rows
- `get_row <doc_id> <table_id> <row_id>`: Get info for a specific row.
- `update_row <doc_id> <table_id> <row_id> <json_data>`: Update a specific row.
- `delete_row <doc_id> <table_id> <row_id>`: Delete a specific row.

### Pages
- `list_pages <doc_id>`: List pages in a document.
- `get_page_info <doc_id> <page_id>`: Get info for a specific page.
- `begin_content_export <doc_id> <page_id> <format>`: Export page content.
- `update_page <doc_id> <page_id> <new_name>`: Update a page's name.
- `delete_page <doc_id> <page_id>`: Delete a specific page.

### Permissions
- `list_permissions <doc_id>`: List permissions for a document.
- `add_permission <doc_id> <email> <access_level>`: Add a permission to a document.
- `remove_permission <doc_id> <permission_id>`: Remove a permission from a document.

### Miscellaneous
- `list_categories`: List categories.
