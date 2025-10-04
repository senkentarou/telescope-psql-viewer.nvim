# telescope-psql-viewer.nvim

A Telescope extension for viewing and searching PostgreSQL database schema information.

## Features

- 🔍 Browse PostgreSQL database schema with Telescope
- 📊 View table columns with their data types and constraints
- 🎯 Smart sorting: prioritizes table name > column name matches
- ✨ Syntax highlighting for search matches
- 📋 Copy column names to clipboard with `<CR>` or `<Tab>`

## Requirements

- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- PostgreSQL client (`psql`) installed and available in PATH

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'senkentarou/telescope-psql-viewer.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    require('telescope').load_extension('psql_viewer')
  end,
}
```

## Configuration

### PostgreSQL Connection

The plugin supports three levels of configuration priority:

1. **Environment variables** (highest priority)
2. **User configuration** via `setup()`
3. **Default values** (fallback)

#### Environment Variables

```bash
export PGHOST=localhost
export PGPORT=5432
export PGUSER=postgres
export PGPASSWORD=your_password
export PGDATABASE=your_database
```

#### User Configuration

You can configure database connection settings in your Neovim config:

```lua
require('telescope').setup {
  extensions = {
    psql_viewer = {
      database = {
        host = 'localhost',
        port = '5432',
        user = 'postgres',
        password = 'your_password',
        database = 'your_database',
      },
      display = {
        column_width = 70,  -- Width for table.column display
        type_width = 30,    -- Width for data type display
        separator = ' | ',  -- Separator between columns
      },
    },
  },
}
```

Or using the setup function directly:

```lua
require('psql_viewer').setup {
  database = {
    host = 'localhost',
    port = '5432',
    user = 'postgres',
    password = 'your_password',
    database = 'your_database',
  },
  display = {
    column_width = 70,
    type_width = 30,
    separator = ' | ',
  },
}
```

#### Default Values

- `host`: localhost
- `port`: 5432
- `user`: postgres
- `password`: postgres
- `database`: postgres

## Usage

### Command

```vim
:Telescope psql_viewer
```

### Lua API

```lua
require('telescope').extensions.psql_viewer.psql_viewer()
```

### Key Mappings

In the Telescope picker:

- `<CR>`: Copy `table.column` to clipboard and close picker
- `<Tab>`: Copy `table.column` to clipboard without closing picker
- `<C-q>`: Close picker
- Standard Telescope navigation keys

## Display Format

The picker displays schema information in the following format:

```
table_name.column_name | data_type | NULL/NOT NULL
```

### Search Priority

When you type a search query, results are sorted by:

1. Exact match with `table.column` format
2. `table.column` starts with query
3. Table name exact match
4. Table name starts with query
5. Table name contains query
6. Column name starts with query
7. Column name contains query
8. Other matches

Example: Typing `users.` will prioritize all columns from the `users` table.

## Examples

### Browse Schema

```lua
:Telescope psql_viewer
```

### Search for Specific Table

Type `users` in the prompt to filter all columns from the `users` table.

### Search for Specific Column

Type `created_at` to find all tables containing a `created_at` column.

### Search Table.Column

Type `users.email` to find the exact column.

## License

MIT
