local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.negcon)
    e1:SetCost(s.negcost)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and Duel.IsChainNegatable(ev) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c, REASON_COST+REASON_DISCARD)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    
    local rc = re:GetHandler()
    if rc and rc:IsRelateToEffect(re) and rc:IsOnField() and rc:IsDestructable() then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,0,0)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateEffect(ev) ~= 0 then
        local has_light = Duel.IsExistingMatchingCard(Card.IsAttribute, tp, LOCATION_MZONE, 0, 1, nil, ATTRIBUTE_LIGHT)
        if has_light then
            local rc = re:GetHandler()
            if rc and rc:IsRelateToEffect(re) and rc:IsOnField() and rc:IsDestructable() then
                Duel.Destroy(rc, REASON_EFFECT)
            end
        end
    end
end