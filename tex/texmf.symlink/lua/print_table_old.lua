
-- Print a table recursively, one line per entry, one tab deeper per
-- level.
function print_table(thetable, level)
    local level = level or 0
    local prefix = "| " .. string.rep("\t", level)
    local set_of_childsigs = set_of_childsigs or { }


    -- print every key
    for k, v in pairs(thetable) do
        print(prefix .. tostring(k), v)
        -- descend into tables (unless we've seen similar)
        if type(v) == "table" then
            -- construct the signature
            local childsig = ""
            for child_k, child_v in pairs(v) do
                childsig = childsig .. child_k .. "--"
            end

            -- descend if the signature is new to us, 
            -- else print a précis.
            if not set_of_childsigs[childsig] then
                set_of_childsigs[childsig] = tostring(k)
                print_table_old(v, level + 1)
            else
                print(prefix, childsig)
            end
        end
    end
end

userdata = userdata or { }
userdata.print_table = print_table
