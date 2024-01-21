local M = {}

M.defaults = {
    documentation_format = "%s\n%s\n%s",
    csv_path = nil,
    completion_column = 1,
}

-- Holds the lines in `csv_path` as Key-Value entries
M.parsed_csv = {}

-- Holds the entries used bei `nvim-cmp` to display completion, thus used in `source.complete()`
M.items = {}

M.setup = function(options)
    vim.validate({
        -- value before '=' is used in error message
        csv_path = { options.csv_path, 'string' },
        documentation_format = { options.documentation_format, 'string' },
    })

    M.defaults = vim.tbl_extend("force", M.defaults, options)

    -- Parse csv
    local file = assert(io.open(M.defaults.csv_path, "r"), "Error opening file: " .. M.defaults.csv_path)
    local lnr = 1
    for line in file:lines() do
        -- values will be referenced by index
        local row = {}
        for value in line:gmatch("[^,]+") do
            table.insert(row, value)
        end
        if M.defaults.completion_column > #row then
            error(string.format("Error: %d exceeds number of values in row %d of file %s",
                M.defaults.completion_column,
                lnr,
                M.defaults.csv_path))
        end
        lnr = lnr + 1
        table.insert(M.parsed_csv, row)
    end
    file:close()

    -- Transform parsed_csv into a table `nvim-cmp` understands
    for _, icu_entry in ipairs(M.parsed_csv) do
        table.insert(M.items, {
            -- `label` is shown in the completion proposals
            label = icu_entry[M.defaults.completion_column],
            -- Window with explanation
            documentation = {
                kind = "text",
                value = string.format(
                    M.defaults.documentation_format,
                    -- table.unpack() doesn't work due to some deprecation issues I don't understand.
                    unpack(icu_entry)
                )
            }
        })
    end

    -- Configure source for `nvim-cmp` based on `M.items`
    local source = {}

    source.new = function()
        local self = setmetatable({ cache = {} }, { __index = source })

        return self
    end

    -- Only enable in `yaml` buffers
    -- s. `h cmp-develop`
    source.is_available = function()
        return vim.bo.filetype == 'yaml' or vim.bo.filetype == 'yml'
    end

    source.complete = function(_, _, callback)
        callback(M.items)
    end

    require("cmp").register_source("cmp-csv", source.new())
end

return M
