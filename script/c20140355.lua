local s, id ,o= GetID()

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id, LOCATION_MZONE)
    
    c:EnableReviveLimit()
    aux.AddXyzProcedure(c, s.xyzfilter, 4, 2, nil, nil, nil, s.ovfilter)
    
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e1:SetTarget(s.distg)
    c:RegisterEffect(e1)
    
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    e2:SetValue(RESET_TURN_SET)
    c:RegisterEffect(e2)
    
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_DESTROY_REPLACE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTarget(s.desreptg)
    e3:SetValue(s.desrepval)
    e3:SetOperation(s.desrepop)
    c:RegisterEffect(e3)
end

function s.xyzfilter(c, xyz, sumtype, sumtype2)
    return c:IsLevel(4)
end

function s.ovfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x1c6) and c:IsType(TYPE_MONSTER)
end

function s.distg(e, c)
    return c:IsSummonLocation(LOCATION_GRAVE)
end

function s.repfilter(c, tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) 
        and c:IsReason(REASON_EFFECT + REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end

function s.desreptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return eg:IsExists(s.repfilter, 1, nil, tp)
            and c:CheckRemoveOverlayCard(tp, 2, REASON_EFFECT)
    end
    return Duel.SelectEffectYesNo(tp, c, 96)
end

function s.desrepval(e, c)
    return s.repfilter(c, e:GetHandlerPlayer())
end

function s.desrepop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if c:RemoveOverlayCard(tp, 2, 2, REASON_EFFECT) then
        Duel.Hint(HINT_CARD, 0, id)
    end
end