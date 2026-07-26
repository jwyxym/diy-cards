--吉尔达利娅
local s,id,o=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,id)
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(aux.IsCodeListed,id),1,1)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
    
    local e0f=Effect.CreateEffect(c)
    e0f:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e0f:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e0f:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0f:SetOperation(s.regop)
    c:RegisterEffect(e0f)
    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.thcost)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
end

function s.gilfilter(c)
    return aux.IsCodeListed(c,id)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end

function s.thfilter(c)
    return s.gilfilter(c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

function s.stfilter(c)
    return s.gilfilter(c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    local sum=Duel.GetActivityCount(tp,ACTIVITY_SUMMON)
    local flpsum=Duel.GetActivityCount(tp,ACTIVITY_FLIPSUMMON)
    local spsum=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
    if sum+flpsum+spsum>=5 then
        e:SetLabel(1)
        Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    else
        e:SetLabel(0)
    end
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
    if e:GetLabel()==0 then return end
    if not Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_DECK,0,1,nil) then return end
    if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local sg=Duel.SelectMatchingCard(tp,s.stfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #sg>0 then
            Duel.SendtoGrave(sg,REASON_EFFECT)
        end
    end
end
