local s,id=GetID()

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
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
    local tg = re:GetTarget()
    if not tg then return false end
    return tg:IsExists(Card.IsOnField, 1, nil) and Duel.IsChainNegatable(ev)
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
    Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    local tg = re:GetTarget()
    if tg and #tg>0 then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,#tg,0,0)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateEffect(ev)~=0 then
        local tg = re:GetTarget()
        if tg and #tg>0 and Duel.IsExistingMatchingCard(Card.IsAttribute, tp, LOCATION_MZONE, 0, 1, nil, ATTRIBUTE_LIGHT) then
            Duel.BreakEffect()
            Duel.Destroy(tg, REASON_EFFECT)
        end
    end
end