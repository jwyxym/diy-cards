function string.endswith(str, suffix)
    return str:sub(-#suffix) == suffix
end

getmetatable("").__index.endswith = string.endswith

require = function (str)
    str = str:endswith(".lua") and str or str..".lua"
    dofile(str)
end
dofile = function (str)
    local len = string.len(str)
    local result=''
    for i=len,1,-1 do
        local temp=""
        temp=string.sub(str,i,i)
        if temp=="/" then
            result=result:endswith(".lua") and result or result..".lua"
            Duel.LoadScript(result)
            return
        end
        result=temp..result
    end
end

