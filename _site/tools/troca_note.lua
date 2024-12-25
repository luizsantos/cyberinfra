-- Script Lua para Pandoc: Transforma '::: note ... :::' em HTML personalizado
function Div(el)
-- Verifica se a classe do Div é 'note'
if el.classes:includes("note") then
    -- Extrai o conteúdo dentro do bloco '::: note ... :::'
    local content = pandoc.utils.blocks_to_inlines(el.content)

    -- Constrói o HTML para a caixa de observação
    local html = [[<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/note.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
 <div class="note">
    ]] .. pandoc.write(pandoc.Pandoc(el.content), "html") .. [[</div></div>]]

    -- Retorna o bloco HTML
    return pandoc.RawInline("markdown", html)
end

if el.classes:includes("important") then
    -- Extrai o conteúdo dentro do bloco '::: note ... :::'
    local content = pandoc.utils.blocks_to_inlines(el.content)

    -- Constrói o HTML para a caixa de observação
    local html = [[<div style="display: flex; align-items: center; border: 1px solid black; padding: 10px; border-radius: 5px; background-color: #333333; color: white; gap: 15px;"><div style="flex-shrink: 0;"><img src="/cyberinfra/img/important.svg" alt="Atenção" style="width: 35px; height: 35px;"></div>
    <div class="note">
    ]] .. pandoc.write(pandoc.Pandoc(el.content), "html") .. [[</div></div>]]

    -- Retorna o bloco HTML
    return pandoc.RawInline("markdown", html)
    end

end
