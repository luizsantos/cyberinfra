return {
  {
    Str = function (elem)
    local texto = elem.text:gsub("{#fig:[^}]*}", "")
    return texto



--[[      if elem.text:find("{#") then
        print(elem.text)
        print(s)
        return elem.text:gsub("{#.-}", "")
      end

      if elem.text == "{{helloworld}}" then
        return pandoc.Emph {pandoc.Str "Hello, World"}
      else
        return elem
      end ]]--
    end,
  }
}
