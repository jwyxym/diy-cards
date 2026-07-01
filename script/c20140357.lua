local s, id ,o= GetID()

function s.initial_effect(c)
    c:SetUniqueOnField(1, 0, id, LOCATION_MZONE)
    
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c, nil, 2, 2, s.lcheck)
    
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
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetCondition(s.handcon)
    e3:SetOperation(s.handes)
    c:RegisterEffect(e3)
end

function s.lcheck(g, lc, tp)
    return g:IsExists(Card.IsSetCard, 1, nil, 0x1c6)
end

function s.distg(e, c)
    return c:IsSummonLocation(LOCATION_HAND) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end

function s.handcon(e, tp, eg, ep, ev, re, r, rp)
    local loc, chain_id = Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_LOCATION, CHAININFO_CHAIN_ID)
    
    if ep == tp then 
        return false 
    end
    
    if not re:IsActiveType(TYPE_MONSTER) then 
        return false 
    end
   
    if loc ~= LOCATION_MZONE then
        return false
    end
    
    if chain_id == s.chain_id then
        return false
    end
    
    if not re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsHasEffect(EFFECT_DISABLE) then
        return false
    end
    
    local c = e:GetHandler()
    if c:GetFlagEffect(id) > 0 then 
        return false 
    end
    
    return true
end

function s.handes(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local chain_id = Duel.GetChainInfo(ev, CHAININFO_CHAIN_ID)
    
    s.chain_id = chain_id
    
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD, 0, 1)
    
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetReset(RESET_EVENT + RESETS_STANDARD)
    c:RegisterEffect(e1)
    
    local op = nil
    if Duel.GetFieldGroupCount(1-tp, LOCATION_HAND, 0) > 0 and 
       Duel.IsExistingMatchingCard(Card.IsAbleToRemove, 1-tp, LOCATION_HAND, 0, 1, nil) then
        if Duel.SelectYesNo(1-tp, aux.Stringid(id, 0)) then
            op = 0
        else
            op = 1
        end
    else
        op = 1
    end
    
    if op == 0 then
        Duel.Hint(HINT_SELECTMSG, 1-tp, HINTMSG_REMOVE)
        local g = Duel.SelectMatchingCard(1-tp, Card.IsAbleToRemove, 1-tp, LOCATION_HAND, 0, 1, 1, nil)
        if #g > 0 then
            Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
        end
    else
        Duel.NegateEffect(ev)
    end
end

s.chain_id = 0