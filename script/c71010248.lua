-- 黑翼的霸王·露法丝·玛法尔
-- id: 71010248

local s, id = GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()

    -- 1. 基础超量：12星×3（官方库）
    aux.AddXyzProcedure(c, nil, 12, 3)

    -- 2. 特殊重叠：纯手写（不判定空地）
    local e_special = Effect.CreateEffect(c)
    e_special:SetDescription(aux.Stringid(id, 2))
    e_special:SetType(EFFECT_TYPE_FIELD)
    e_special:SetCode(EFFECT_SPSUMMON_PROC)
    e_special:SetProperty(EFFECT_FLAG_UNCOPYABLE + EFFECT_FLAG_CANNOT_DISABLE)
    e_special:SetRange(LOCATION_EXTRA)
    e_special:SetTargetRange(POS_FACEUP_ATTACK, 0)
    e_special:SetValue(SUMMON_TYPE_XYZ) 
    e_special:SetCountLimit(1, id + 100) 
    e_special:SetCondition(s.xyzcon1)
    e_special:SetTarget(s.xyztg1)
    e_special:SetOperation(s.xyzop1)
    c:RegisterEffect(e_special)

    -- 规则上视为同名
    local e_alias = Effect.CreateEffect(c)
    e_alias:SetType(EFFECT_TYPE_SINGLE)
    e_alias:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e_alias:SetCode(EFFECT_ADD_CODE)
    e_alias:SetValue(71000242)
    c:RegisterEffect(e_alias)

    -- ● 攻击力上升
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.matcon)
    e4:SetValue(s.atkval)
    c:RegisterEffect(e4)

    -- ● 效果免疫
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_IMMUNE_EFFECT)
    e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCondition(s.matcon)
    e5:SetValue(s.efilter)
    c:RegisterEffect(e5)

    -- ①：离场后结束阶段拉普通露法丝
    local e7 = Effect.CreateEffect(c)
    e7:SetDescription(aux.Stringid(id, 1))
    e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e7:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e7:SetCode(EVENT_PHASE + PHASE_END)
    e7:SetProperty(EFFECT_FLAG_DELAY)
    e7:SetRange(LOCATION_GRAVE + LOCATION_REMOVED)
    e7:SetCountLimit(1)
    e7:SetCondition(s.spcon)
    e7:SetTarget(s.sptg)
    e7:SetOperation(s.spop)
    c:RegisterEffect(e7)

    -- ②：无素材攻防变0
    local e8 = Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_SINGLE)
    e8:SetCode(EFFECT_SET_ATTACK)
    e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e8:SetRange(LOCATION_MZONE)
    e8:SetCondition(s.nomatcon)
    e8:SetValue(0)
    c:RegisterEffect(e8)

    local e9 = e8:Clone()
    e9:SetCode(EFFECT_SET_DEFENSE)
    c:RegisterEffect(e9)
end

function s.matfilter1(c)
    return c:IsCode(71000242) and c:IsLevel(12)
end

-- 【核心修复】去掉 GetLocationCountFromEx 判定
function s.xyzcon1(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    return Duel.IsExistingMatchingCard(s.matfilter1, tp, LOCATION_MZONE, 0, 1, nil)
end

function s.xyztg1(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return s.xyzcon1(e, nil) end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local g = Duel.SelectMatchingCard(tp, s.matfilter1, tp, LOCATION_MZONE, 0, 1, 1, nil)
    if #g > 0 then
        g:KeepAlive()
        e:SetLabelObject(g)
        return true
    end
    return false
end

function s.xyzop1(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = e:GetLabelObject()
    if not g then return end
    local mg = g:Filter(Card.IsLocation, nil, LOCATION_MZONE)
    if mg:GetCount() > 0 then
        c:SetMaterial(mg)
        Duel.Overlay(c, mg) 
    end
    g:DeleteGroup()
end

function s.matcon(e)
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode, 1, nil, 71000242)
end

function s.nomatcon(e)
    return not s.matcon(e)
end

function s.atkval(e, c)
    local g = Duel.GetMatchingGroup(Card.IsFaceup, 0, LOCATION_MZONE, LOCATION_MZONE, nil)
    local races = {} local ct = 0
    for tc in aux.Next(g) do
        local race = tc:GetRace()
        if not races[race] then races[race] = true ct = ct + 1 end
    end
    return ct * 1000
end

function s.efilter(e, te)
    if not te:IsActiveType(TYPE_MONSTER) then return false end
    local rc = te:GetHandler()
    return rc and rc:IsType(TYPE_MONSTER) and rc:GetAttack() < e:GetHandler():GetAttack()
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp) 
    local c = e:GetHandler()
    return c:GetTurnID() == Duel.GetTurnCount() and c:IsPreviousLocation(LOCATION_MZONE) 
end

function s.spfilter(c, e, tp) 
    return c:IsCode(71000242) and c:IsLevel(12)
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 
            and Duel.IsExistingMatchingCard(s.spfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, 1, nil, e, tp)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_GRAVE + LOCATION_REMOVED)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
    if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
    local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_GRAVE + LOCATION_REMOVED, 0, nil, e, tp)
    if g:GetCount() == 0 then return end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local sg = g:Select(tp, 1, 1, nil)
    if sg:GetCount() > 0 then
        local tc = sg:GetFirst()
        Duel.SpecialSummon(tc, 0, tp, tp, true, true, POS_FACEUP)
    end
end