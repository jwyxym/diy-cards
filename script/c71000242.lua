-- 露法丝·玛法尔
-- id: 71000242

local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit() -- 开启苏生限制

    -- ①：这张卡不能通常召唤。用「女神的魔法·艾克斯之门」或「黑翼的霸王」·露法丝·玛法尔的效果才能从手卡·墓地特殊召唤。
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetValue(s.splimit)
    c:RegisterEffect(e1)

    -- ②：这张卡不受攻击力比这张卡低的怪兽的效果影响。
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE + EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(s.efilter)
    c:RegisterEffect(e2)
end

-- ① 特殊召唤限制（只允许特定来源特召）
function s.splimit(e, se, sp, st)
    return se and (se:GetCode() == 71000254 or (se:GetHandler() and se:GetHandler():IsCode(71010248)))
end

-- ② 效果免疫（攻击力低于这张卡的怪兽效果无法影响它）
function s.efilter(e, re)
    if not re:IsActiveType(TYPE_MONSTER) then return false end
    local rc = re:GetHandler()
    if not rc:IsRelateToEffect(re) then return false end
    return rc:GetAttack() < e:GetHandler():GetAttack()
end