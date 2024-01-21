# cmp-csv

This plugin will add completion for the values of an arbitrary column of a `csv`-file.

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
  documentation_format = '',
  csv_path = '' -- No csv, no party 😞
  filetype = '',
  completion_column = 1,
  skip_rows = 0
})
```
- `documentation_format`: Lua format string, should contain three `%s`. No checks are performed, example: `%s (Col 1)\n%s (Col 2)\n%s (Col 3)`.
- `csv_path`: Path to the `csv`-file to generated sources for [nvim-cmp](https://github.com/hrsh7th/nvim-cmp). Without a `csv`-file no sources can be established and `setup()` will fail. No consistency checks for the `csv` are performed[^1]. 
- `filetype`: In which buffers we wish to have the completion.
- `completion_column`: Which column of your CSV is used for syntax completion. If it exceeds the number of values in one row, an error is thrown.
- `skip_rows`: First rows to skip in case there are header information. An error is thrown if `skip_rows` exceeds the line number of `csv_path`.

## Enabling within [nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
```lua
require("cmp").setup({
  sources = {
    { name = "cmp_csv" }, -- _ not - 😯
  }
})
```

## Acknowledgements
- [TJ DeVires](https://github.com/tjdevries) video on [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) was a great help and is an inspiration: [TakeTuesday E01: nvim-cmp](https://www.youtube.com/watch?v=_DnmphIwnjo)

[^1]: Currently, no space(s) around the `,` are skipped, ie. `John ,...` will capture `John ` (there is a whitespace after `John`).
