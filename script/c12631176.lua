-- 机块紧急熔断
local s,id=GetID()
local SET_KIHAI=0x014b

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_MOVE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

s.listed_series={SET_KIHAI}

function s.linkfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(SET_KIHAI)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not re then return false end
    if not Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_MZONE,0,1,nil) then return false end
    if re:IsActiveType(TYPE_MONSTER) then
        return true
    end
    if re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then
        return true
    end
    return false
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(re:GetHandler(),REASON_EFFECT)
    end
end

function s.mvfilter(c,tp)
    return c:IsSetCard(SET_KIHAI) and c:IsType(TYPE_MONSTER)
        and c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsLocation(LOCATION_MZONE)
        and c:IsControler(tp)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.mvfilter,1,nil,tp)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    end
end
