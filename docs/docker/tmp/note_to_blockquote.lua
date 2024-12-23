local utils = require 'pandoc.utils'

function Div (elem)
if elem.classes and elem.classes[1] == "note" then
    local content = {}
    for i, v in ipairs(elem.content) do
        table.insert(content, utils.Str("> ")) -- Usa utils.Str
        table.insert(content, v)
        table.insert(content, utils.LineBreak) -- Usa utils.LineBreak
        end
        return {pandoc.Para(content)} -- Usa pandoc.Para
        end
        return elem
        end
