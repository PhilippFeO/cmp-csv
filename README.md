# cmp-csv

This plugin will add completion for the values of the first column of a `csv`-file having three columns in total.

## Outline
As you may already have guessed, the application horizon is quite limited. In the next days, I will work on extending the plugin to use an arbitrary column of a `csv`-file with arbitrary columns.

## Installation (Lazy.nvim)
```lua
{
  'PhilippFeO/cmp-csv',
  opts {
    -- see below
  }
}
```

## Default configuration
There are currently two options, one, `csv_path`, is mandatory.
```lua
require('cmp-csv').setup({
  documentation_format = "%s\n%s\n%s",
  csv_path = nil -- No csv, no party
})
```
- `documentation_format`: Lua format string, should contain three `%s`. No checks are performed, example: `%s (Col 1)\n%s (Col 2)\n%s (Col 3)`.
- `csv_path`: Path to the `csv`-file to generated sources for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp). Without a `csv`-file no sources can be generated and `setup()` will fail. No consistency checks for the `csv` are performed[^1]. 

## Enabling within [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
```lua
require("cmp").setup({
  sources = {
    { name = "cmp-csv" },
  }
})
```

## Acknowledgements
- [TJ DeVires](https://github.com/tjdevries) video on [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) was a great help and is an inspiration: [TakeTuesday E01: nvim-cmp](https://www.youtube.com/watch?v=_DnmphIwnjo)

[^1]: Currently, no space(s) around the `,` are skipped, ie. `John ,...` will capture `John ` (there is a whitespace after `John`).
