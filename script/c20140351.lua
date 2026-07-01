local s, id = GetID()

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id, LOCATION_MZONE)
    
    c:EnableReviveLimit()
    aux.AddFusionProcFunRep(c, s.ffilter, 2, true)
    
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e1:SetCode(EFFECT_SPSUMMON_CONDITION)
    e1:SetValue(s.splimit)
    c:RegisterEffect(e1)
    
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    e2:SetCode(EFFECT_SPSUMMON_PROC)
    e2:SetRange(LOCATION_EXTRA)
    e2:SetCondition(s.hspcon)
    e2:SetTarget(s.hsptg)
    e2:SetOperation(s.hspop)
    c:RegisterEffect(e2)
    
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(aux.tgoval)
    c:RegisterEffect(e3)
    
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_ATTACK_ALL)
    e4:SetValue(1)
    c:RegisterEffect(e4)
    
    local e5 = Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_PIERCE)
    c:RegisterEffect(e5)
end

function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end

function s.ffilter(c)
    return c:IsSetCard(0x1c6) and c:IsType(TYPE_MONSTER)
end

function s.hspfilter(c, tp, sc)
    return c:IsSetCard(0x1c6) and c:IsType(TYPE_MONSTER) and c:IsControler(tp) 
        and c:IsReleasable(REASON_SPSUMMON) and c:IsCanBeFusionMaterial(sc, SUMMON_TYPE_SPECIAL)
end

function s.hspchk(g, tp, sc)
    return Duel.GetLocationCountFromEx(tp, tp, g, sc) > 0
end

function s.hspcon(e, c)
    if c == nil then return true end
    local tp = c:GetControler()
    local rg = Duel.GetMatchingGroup(s.hspfilter, tp, LOCATION_MZONE, 0, nil, tp, e:GetHandler())
    return rg:CheckSubGroup(s.hspchk, 2, 2, tp, e:GetHandler())
end

function s.hsptg(e, tp, eg, ep, ev, re, r, rp, chk, c)
    local rg = Duel.GetMatchingGroup(s.hspfilter, tp, LOCATION_MZONE, 0, nil, tp, e:GetHandler())
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RELEASE)
    local sg = rg:SelectSubGroup(tp, s.hspchk, true, 2, 2, tp, e:GetHandler())
    if sg then
        sg:KeepAlive()
        e:SetLabelObject(sg)
        return true
    else
        return false
    end
end

function s.hspop(e, tp, eg, ep, ev, re, r, rp, c)
    local g = e:GetLabelObject()
    Duel.Release(g, REASON_SPSUMMON)
    g:DeleteGroup()
end