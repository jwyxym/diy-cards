-- 「霸道十二星天」·牧羊的艾瑞斯
-- id: 71010272

local s, id = GetID()
local ARIEL_ID = 71000266

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

    local e_alias = Effect.CreateEffect(c)
    e_alias:SetType(EFFECT_TYPE_SINGLE)
    e_alias:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e_alias:SetCode(EFFECT_ADD_CODE)
    e_alias:SetValue(ARIEL_ID)
    c:RegisterEffect(e_alias)

    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id, 0))
    e4:SetCategory(CATEGORY_DAMAGE)
    e4:SetType(EFFECT_TYPE_TRIGGER_O + EFFECT_TYPE_FIELD)
    e4:SetCode(EVENT_ATTACK_ANNOUNCE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.damcon)
    e4:SetTarget(s.damtg)
    e4:SetOperation(s.damop)
    c:RegisterEffect(e4)

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
    return c:IsCode(ARIEL_ID) and c:IsLevel(12) and not c:IsType(TYPE_XYZ)
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
    return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode, 1, nil, ARIEL_ID)
end

function s.nomatcon(e)
    return not s.matcon(e)
end

function s.damcon(e, tp, eg, ep, ev, re, r, rp)
    if not s.matcon(e) then return false end
    local a = Duel.GetAttacker()
    local d = Duel.GetAttackTarget()
    if a:GetControler() ~= tp then return false end
    if not d or d:GetControler() == tp then return false end
    if not (a == e:GetHandler() or a:IsCode(71000242)) then return false end
    return Duel.IsExistingMatchingCard(Card.IsCode, tp, LOCATION_MZONE, 0, 1, nil, 71000242)
end

function s.damtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then return true end
    local d = Duel.GetAttackTarget()
    Duel.SetTargetCard(d)
    local dmg = math.floor(math.max(d:GetBaseAttack(), 0) / 2)
    Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dmg)
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
    local d = Duel.GetAttackTarget()
    if d and d:IsRelateToBattle() then
        local atk = math.max(d:GetBaseAttack(), 0)
        if atk > 0 then
            Duel.Damage(1 - tp, math.floor(atk / 2), REASON_EFFECT)
        end
    end
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp) 
    local c = e:GetHandler()
    return c:GetTurnID() == Duel.GetTurnCount() and c:IsPreviousLocation(LOCATION_MZONE) 
end

function s.spfilter(c, e, tp) 
    return c:IsCode(ARIEL_ID) and c:IsLevel(12)
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