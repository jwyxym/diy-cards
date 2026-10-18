-- 灭亡之烬冥 威多释
local s,id,o=GetID()
local SET_HAIMETSU=0x1ad
local CARD_HAIMETSU_CITY=3055018
local CARD_VIDOS=78783557

function s.initial_effect(c)
    aux.AddFusionProcMixRep(c,true,true,s.ffilter_pyro,1,5,CARD_VIDOS,s.ffilter_dark)
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.discon)
    e1:SetTarget(s.distg)
    e1:SetOperation(s.disop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e4:SetValue(s.efilter)
    c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,2))
    e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1,id+o)
    e5:SetCondition(s.negcon)
    e5:SetCost(s.negcost)
    e5:SetTarget(s.negtg)
    e5:SetOperation(s.negop)
    c:RegisterEffect(e5)
end

s.listed_series={SET_HAIMETSU}

function s.ffilter_dark(c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_FUSION)
        and not c:IsCode(CARD_VIDOS)
end

function s.ffilter_pyro(c)
    return c:IsRace(RACE_PYRO) and c:IsType(TYPE_MONSTER)
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

function s.disfilter(c)
    return c:IsFaceup()
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_ONFIELD,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.disfilter,tp,0,LOCATION_ONFIELD,nil)
    if #g==0 then return end
    Duel.HintSelection(g)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
    end
end

function s.efilter(e,re,rp)
    return re:IsActiveType(TYPE_MONSTER) and e:GetHandlerPlayer()~=re:GetHandlerPlayer()
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re)
        and rp~=tp
        and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

function s.costfilter(c)
    return c:IsCode(CARD_HAIMETSU_CITY) and c:IsAbleToGraveAsCost()
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK+LOCATION_ONFIELD,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK+LOCATION_ONFIELD,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end