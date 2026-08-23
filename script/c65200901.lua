-- 僵尸衍生物
local s, id = GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
end