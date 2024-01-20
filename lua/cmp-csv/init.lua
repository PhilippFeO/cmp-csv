-- TODO: Let user decide which entry in CSV is used for completion <19-01-2024>

local M = {}

M.defaults = {
    documentation_format = "%s\n%s\n%s",
    -- TODO: Remove default value and make csv_path obligatory by checking it's existence, ie. throw an error when missing <19-01-2024>
    csv_path = nil
}

-- Holds the lines in `csv_path` as Key-Value entries
-- TODO: Key-Value probably not necessary since they will be ordered as defined in csv <19-01-2024>
-- Also: Key-Value is an obstacle to generalize to arbitrary values in one line
M.parsed_csv = {}

-- Holds the entries used bei `nvim-cmp` to display completion, thus used in `source.complete()`
M.items = {}

M.setup = function(options)
    -- print(vim.inspect(options))
    vim.validate({
        csv_path = { options.csv_path, 'string' },
        documentation_format = { options.documentation_format, 'string' },
    })
    -- print(vim.inspect(options))

    M.defaults = vim.tbl_extend("force", M.defaults, options)

    -- Parse csv
    local file = assert(io.open(M.defaults.csv_path, "r"), "Error opening file: " .. M.defaults.csv_path)
    for line in file:lines() do
        local name, category, url = line:match("([^,]+),([^,]+),([^,]+)")

        -- Check if all fields are present
        if name and category and url then
            table.insert(M.parsed_csv, { ingredient = name, category = category, url = url })
        else
            print("Skipping invalid line:", line)
        end
    end
    file:close()

    -- Transform parsed_csv into a table `nvim-cmp` understands
    for _, icu_entry in ipairs(M.parsed_csv) do
        table.insert(M.items, {
            -- `label` is shown in the completion proposals
            label = icu_entry.ingredient,
            -- `Window with explanation`
            documentation = {
                kind = "text",
                value = string.format(
                    M.defaults.documentation_format,
                    icu_entry.ingredient,
                    icu_entry.category,
                    icu_entry.url
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
