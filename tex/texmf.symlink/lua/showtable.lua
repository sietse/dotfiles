-------- General description

-- Usage:
-- u.print_table(
--      thetable,   -- The table to print, one line per entry
--      { tablename,  -- Its name, if you want that printed at the start
--        everything, -- Whether to descend repeatedly into similar subtables.
--                       False by default.
--        statter,    -- A function which is called on a table before
--                       printing its entry and possibly descending into
--                       it. Defaults to `getstats()`, but you can specify
--                       your own plug-in replacement. Expected to return
--                       a table containing at least `maxkeylength`,
--                       `signature`, and `ordertable`. The stats table is
--                       passed to the printer function, and also to the
--                       do_print_table that descends into the table.
--        printer     -- Defaults to `printline()`. Prints the current line,
--      }                on the basis of `(k, v, path, stats_of_self,
--                       stats_of_v, known)`. `known` will be true if v is
--                       a table, and we have previously seen a sibling
--                       table with the same signature.
-- )

-- Output is something like the following:
-- T.aap                 : 1
-- T.function: 0x9e39a78 : nil
-- T.karolus             : table: 0x9e3d228
-- T.karolus.aap                : function: 0x9e39998
-- T.karolus.noot               : 8
-- T.karolus.wimpjewimpjewimpje : jjjjjj
-- T.noot                : 2
-- T.wortel              : table: 0x9e3d0b0 (like T.karolus)

-------- Functions

-- Traverse a table once, and return a table with the following fields:
--      `maxkeylength`: the longest key name in the table.
--      `signature`: used by do_print_table. If the same signature is
--          encountered twice, then the second time the default
--          behaviour of do_print_table is to not descend.
--      `ordertable`: used by do_print_table to traverse over the the keys
--          of thetable in (alphabetical) order
--
-- The table is also passed to the printer function. (Default one is
-- `printline`.) So, you may specify an alternative printing function
-- that depends on knowledge of other fields, and write an alternative
-- to getstats that collects that knowledge and returns it in its table.

local function getstats(thetable)
    local signaturetable = { }
    -- k is not sortable; tostring(k) is. So: 
    -- store the string in ordertable; 
    -- store string->object maps in string_orig_table;
    -- sort the strings, and put back the objects
    local ordertable = { } -- stores tostring(k). Is sortable.
    local string_orig_table = { }    -- maps tostring(k) to k.
    local maxkeylength = 0

    for k, v in pairs(thetable) do
        -- gather 'key:type' for the signatures
        table.insert(signaturetable, tostring(k) .. ':' .. type(v))
        -- store strings for sorting, string->object for replacing
        table.insert(ordertable, tostring(k))
        string_orig_table[tostring(k)] = k

        -- update max_key_length
        local l = string.len(tostring(k))
        if maxkeylength < l then maxkeylength = l end
    end

    -- sort the strings, then put back the objects.
    table.sort(ordertable)
    for i, kstring in ipairs(ordertable) do
        ordertable[i] = string_orig_table[kstring]
    end

    -- turn the signature table into a proper signature
    table.sort(signaturetable)
    signature = table.concat(signaturetable, '--')

    -- return the statistics table
    return({
        signature = signature,
        ordertable = ordertable,
        maxkeylength = maxkeylength
    })
end

local function getstats3(thetable)
    local ordertable = table.sortedkeys(thetable)
    local signaturetable = { }
    local maxkeylength = 0
    for i=1,#ordertable do
        local o = ordertable[i]
        signaturetable[i] = tostring(i) .. ':' .. type(thetable[o])
        if string.len(tostring(o)) > maxkeylength then
            maxkeylength = string.len(tostring(o))
        end
    end
    return {
        signature = table.concat(signaturetable, '--'),
        ordertable = ordertable,
        maxkeylength = maxkeylength
    }
end

-- Given a key and a value, plus some extra info, pretty-print them.
-- k: the key. Required.
-- v: the value. Required.
-- stats_of_self: Required. a table that contains these entries: 
--     maxkeylength: the length of the longest key in the table that
--          contains k and its siblings
--     depth: recursion level. Initially level 0.
--     path: If k is at the.table.k, the path is "the.table".
-- stats_of_v: Required if known == true. Must contain these entries:
--      similar_sibling
-- known: whether a similar sibling exists. If yes, printline refers to
--      that sib.
local function printline(k, v, stats_of_self, stats_of_v, known)
    path         = stats_of_self.path or ''
    maxkeylength = stats_of_self.maxkeylength
    k            = tostring(k)
    v            = tostring(v)

    if known then
        v = tostring(v) .. ' (like ' .. stats_of_v.similar_sibling .. ')' 
    end
    -- stats.maxkeylength = longest key in current v
    --       maxkeylength = longest key among k and its siblings
    commands.writestatus("showtable", string.format(
        "%-"..maxkeylength.."s : %s",  -- "%-10s : %s"
        path .. '.' .. k,
        v
    )) 
end

-- Print a table, one line per entry. If the entry is itself a table,
-- recurse into it (unless the table is known, and `everything` =
-- `false`.)
local function do_print_table(thetable, stats_of_self, 
                              everything, statter, printer)
    local setofchildsigs = { }

    -- Traverse the entries of thetable in alphabetical order
    -- (alphabetical order kindly supplied by ordertable)
    for i, k in ipairs(stats_of_self.ordertable) do

        local v = thetable[k]
        -- if it's a table, decide whether to descend;
        if type(v) == "table" then
            -- construct the signature
            local stats_of_v = statter(v)
            -- Attention! The stats table also stores the values
            -- depth and path, and not just what the statter returns.
            stats_of_v.depth = stats_of_self.depth + 1
            stats_of_v.path  = stats_of_self.path .. '.' .. k

            -- if the sig is known, and we don't print everything, 
            -- print 'the.table : (like the.siblingtable)'
            if setofchildsigs[stats_of_v.signature] and 
                    not everything then
                stats_of_v.similar_sibling = 
                    setofchildsigs[stats_of_v.signature]
                printer(k, v, stats_of_self, stats_of_v, true)

            -- for unknown sigs, or if we print everything: 
            -- record the sig, print the line, and descend.
            else
                setofchildsigs[stats_of_v.signature] = 
                    stats_of_self.path .. '.' .. k
                printer(k, v, stats_of_self, stats_of_v, false)
                do_print_table(
                    v, stats_of_v, 
                    everything, statter, printer
                )
            end
        -- end of the 'if it's a table' block
        -- if it's not a table, simply print it.
        else
            printer(k, v, stats_of_self, stats_of_v, false)
        end
    end -- end for
end

-- Front-end that takes care of default options.
-- specify an option like so:
-- print_table(jan, {everything = true})
local function print_table(thetable, opts)
    local opts = opts or { }

    if type(thetable) ~= 'table' then
        commands.writestatus("showtable", 
            "%s is not a table.",
            opts.tablename or 'This'
        )
        return 0
    end

    local tablename  = opts.tablename  or 'T'
    local everything = opts.everything or false
    local statter    = opts.statter    or getstats
    local printer    = opts.printer    or printline

    local stats = statter(thetable)
    -- Attention! The stats table also stores the values depth and path,
    -- and not just what the statter returns.
    stats.depth = 0
    stats.path = tablename
    do_print_table(thetable, stats, everything, statter, printer)
end            

-------- Make it available

userdata = userdata or { }
userdata.showtable = print_table

-------- Testing code, for them what want it.

--[[
    jan = { 
        aap = 1, 
        noot = 2, 
        wortel = { 
            wimpjewimpjewim = 'asdfjkl', 
            aap = function (x)
              print 'asdf'
            end,   
            noot = 8
        },
        [999] = 12,
        karolus = { 
            wimpjewimpjewim = 'jjjjjj', 
            bap = function (x)
                Y = Y + 1
                print 'bsdf'
            end,   
            noot = 8
        }
    }

    -- keys can be functions or objects, too
    -- vent = function(x) print('jk') end
    -- jan[vent] = 66
    -- jan.wortel[vent] = 88

    --userdata.showtable(jan)
    --userdata.showtable(jan, {statter = getstats3})
    userdata.showtable(jan)
    --inspect(jan)

--]]
