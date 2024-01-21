local M = {}

M.defaults = {
    documentation_format = '',
    csv_path = '',
    -- TODO: It is probably better to let nvim-cmp control this option directly but currently I don't know how. <21-01-2024>
    filetype = '',
    completion_column = 1,
    skip_rows = 0
}

-- Holds the lines in `csv_path` as Key-Value entries
M.parsed_csv = {}

-- Holds the entries used bei `nvim-cmp` to display completion, thus used in `source.complete()`
M.items = {}

M.setup = function(options)
    vim.validate({
        -- value before '=' is used in error message
        documentation_format = { options.documentation_format, 'string' }, -- Will throw error on empty string ('' == nil != string)
        csv_path = { options.csv_path, 'string' },
        filetype = { options.filetype, 'string' },
        completion_column = { options.completion_column, 'number', true },
        skip_rows = { options.skip_rows, 'number', true }
    })

    options.csv_path = vim.fn.expand(options.csv_path)
    M.defaults = vim.tbl_extend("force", M.defaults, options)

    -- Parse csv
    local file = assert(io.open(M.defaults.csv_path, "r"), "Error opening file: " .. M.defaults.csv_path)
    local lnr = 1
    for line in file:lines() do
        if lnr <= M.defaults.skip_rows then
            -- Having one `lnr = lnr + 1` after `::continue::` throws error '<goto continue> jumps into the scope of local 'row''
            lnr = lnr + 1
            goto continue
        end
        -- values will be referenced by index
        local row = {}
        for value in line:gmatch("[^,]+") do
            table.insert(row, value)
        end
        if M.defaults.completion_column > #row then
            local error_msg = string.format(
                "Error: %d exceeds number of values in row %d of file %s",
                M.defaults.completion_column,
                lnr,
                M.defaults.csv_path)
            error(error_msg)
        end
        lnr = lnr + 1
        table.insert(M.parsed_csv, row)
        ::continue::
    end
    file:close()

    if #M.parsed_csv == 0 then
        local error_msg = string.format(
            "You may have skipped more rows (%d) than '%s' provides. You won't receive any completion based on your CSV file.",
            M.defaults.skip_rows,
            M.defaults.csv_path)
        error(error_msg)
    end

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

    -- Only enable in certain buffers
    -- s. `h cmp-develop`
    source.is_available = function()
        return vim.bo.filetype == M.defaults.filetype
    end

    source.complete = function(_, _, callback)
        callback(M.items)
    end

    require("cmp").register_source("cmp_csv", source.new())
end

return M
