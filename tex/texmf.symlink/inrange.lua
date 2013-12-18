--  Create a function that turns
--  \refwithranges[fig:a, fig:b, fig:c, fig:x, fig:z]
--  into
--  Figures 1-3,24,26

local report = logs.reporter("inrange")
local errorcode = -99

--- [PHG] use locals for faster lookups
local tablesort = table.sort

-- Given an array of numbers, return an array of runs in that list.
-- Each run is itself an array with elements ["start"] and ["stop"]
-- Pre-sorting is left in the user's hands
local function get_runs(a)
    local runs = { }
    local run_start = 1
    while run_start <= #a do
        local run_stop = run_start
        -- TODO replace a[run_stop] + 1 with
        -- increment_number_string(a[run_stop])
        -- that turns '1.2.1' into '1.2.2'
        -- so we can get runs among prefixed numbers, too.
        if a[run_stop] <= -100 then
            report("Ignoring entry %d", a[run_stop])
        else
            while a[run_stop + 1] == a[run_stop] + 1 do
                run_stop = run_stop + 1
            end
            report("%s--%s", run_start, run_stop)
            --- [PHG] table.insert is slow, better append explicitly
            runs[#runs+1] = {
              start = a[run_start],
              stop  = a[run_stop],
            }
        end
        run_start = run_stop + 1
    end
    return runs
end

-- Given a reference string, return the figure/section/table number
-- Yes, invoking this on multiple strings operates in quadratic time.
-- Solution: assume n to be small
-- A helper function for this should exist somewhere
local function number_from_ref(refstring)
    -- TODO ensure we only run when structures.lists.ordered.float
    -- already exists
    --- [PHG] next() is the fastest iterator
    for k,v in next, structures.lists.ordered.float.figure do
        -- TODO if we return the full '1.2.1' string here
        -- then adapt get_runs as stated there, we can process prefixed
        -- numbers, too.
        if refstring == v.references.reference then
            report("%s --> %s", refstring, v.numberdata.numbers[1])
            return v.numberdata.numbers[1]
        end
    end
    errorcode = errorcode - 1
    report("Unknown reference: %s, returning %d", refstring, errorcode)
    return errorcode
end


-- Input: an array of runs,
-- Action: print something like '1, 3-5, and 8'
local function typeset_runs(runs, args)
    local args = args or { }
    local range_char = args["range_char"] or '-'
    local run_sep    = args["run_sep"] or ', '
    local last_sep   = args["last_sep"] or run_sep

    local i = 0
    for _, run in next,runs do
        if 0 < i then
            if i < #runs - 1 then
                context(run_sep)
            elseif i == #runs - 1 then
                context(last_sep)
            end
        end
        i = i + 1

        --- [PHG] use cld here -- looks more organized
        context["in"]({run.start})
        if run.start ~= run.stop then
            context(range_char)
            context["in"]({run.stop})
        end
    end
end

-- User-facing function: 
local function inrange(str)
    if not structures.lists.ordered.float then
        -- float table does not yet exist, do nothing this run
        return false
    end

    local refstrings_unsorted = utilities.parsers.settings_to_array(str)
    local refstrings          = { }
    local numbers             = { }

    -- turn refstrings into numbers, and remember what goes with what
    for _, ref in next,refstrings_unsorted do
        local n = number_from_ref(ref)
        numbers[#numbers+1] = n
        refstrings[n]       = ref
    end
    -- sort the numbers, and turn them into a runs table
    tablesort(numbers)
    local runs = get_runs(numbers)

    -- replace the numbers in the runs table with refstrings, and
    -- typeset
    for k, run in next,runs do
        runs[k].start = refstrings[run.start]
        runs[k].stop = refstrings[run.stop]
    end
    typeset_runs(runs, {last_sep = ' and '})
end

userdata = userdata or { }
userdata.get_runs = get_runs
userdata.inrange = inrange

