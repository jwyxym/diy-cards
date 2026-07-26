--斩奏医疗兵
local s,id=GetID()
local GIL_CODE=57300009

function s.initial_effect(c)
    aux.AddCodeList(c,GIL_CODE)
    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SSET)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.ssetcon)
    e2:SetCost(s.ssetcost)
    e2:SetTarget(s.ssettg)
    e2:SetOperation(s.ssetop)
    c:RegisterEffect(e2)
end

function s.isCodeListed(c)
    return aux.IsCodeListed(c,GIL_CODE)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return not c:IsReason(REASON_DRAW) 
        and c:IsPreviousLocation(LOCATION_DECK+LOCATION_GRAVE)
end

function s.thfilter(c)
    return s.isCodeListed(c) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.ssetcon(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetTurnPlayer()~=tp then return false end
    if not Duel.IsMainPhase() then return false end
    local sum=Duel.GetActivityCount(tp,ACTIVITY_SUMMON)
    local spsum=Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)
    return sum+spsum>=5
end

function s.ssetcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end

function s.ssetfilter(c)
    return s.isCodeListed(c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

function s.ssettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.ssetfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_SSET,nil,1,tp,LOCATION_GRAVE)
end

function s.ssetop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.ssetfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.SSet(tp,tc)>0 then
       
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
            e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            
            if tc:IsType(TYPE_QUICKPLAY) then
                local e2=Effect.CreateEffect(e:GetHandler())
                e2:SetType(EFFECT_TYPE_SINGLE)
                e2:SetCode(EFFECT_QP_ACT_IN_SET_TURN)
                e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
                e2:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e2)
            end
        end
    end
end

