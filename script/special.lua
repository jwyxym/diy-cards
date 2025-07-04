require = function (str)
    dofile(str..".lua")
end
dofile = function (str)
    local len = string.len(str)
    local result=''
    for i=len,1,-1 do
        local temp=""
        temp=string.sub(str,i,i)
        if temp=="/" then
            result=result..".lua"
            Duel.LoadScript(result)
            return
        end
        result=temp..result
    end
end