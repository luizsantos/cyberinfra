-- Função para remover as tags {#fig:...}
local function remove_figure_tag(text)
    return text:gsub("{#fig:[^}]*}", "")
end

-- Processa blocos de texto
function RawBlock(el)
    -- Remove as tags de blocos de texto bruto
    el.text = remove_figure_tag(el.text)
    return el
end

-- Processa elementos inline
function RawInline(el)
    -- Remove as tags de texto inline
    el.text = remove_figure_tag(el.text)
    return el
end

-- Processa parágrafos e outros elementos de texto
function Para(el)
    for i, inline in ipairs(el.content) do
        if inline.t == "Str" then
            inline.text = remove_figure_tag(inline.text)
        end
    end
    return el
end

