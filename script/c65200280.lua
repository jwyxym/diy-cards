local s,id=GetID()

function s.initial_effect(c)
    aux.AddCodeList(c, 65200270)
    c:EnableReviveLimit()
    aux.AddRitualProcGreater(c,s.ritual_filter)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.thcon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.ritual_filter(c)
    return c:IsRace(RACE_ZOMBIE)
end

function s.relfilter(c)
    return c:IsReleasable()
end

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        local mg=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,0,nil)
        return c:IsLocation(LOCATION_HAND) and mg:GetCount()>0
    end
    Duel.ConfirmCards(1-tp, c)
    local mg=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_MZONE,0,nil)
    local high=mg:Filter(function(c) return c:GetLevel()>=3 end,nil)
    local sg
    if high:GetCount()>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        sg=high:Select(tp,1,1,nil)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        sg=mg:Select(tp,1,2,nil)
        local sum=0
        local tc=sg:GetFirst()
        while tc do
            sum=sum+tc:GetLevel()
            tc=sg:GetNext()
        end
        if sum<3 then return end
    end
    if sg:GetCount()==0 then return end
    local atk=0
    local tc=sg:GetFirst()
    while tc do
        atk=atk+tc:GetBaseAttack()
        tc=sg:GetNext()
    end
    e:SetLabel(atk)
    Duel.Release(sg,REASON_COST)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsLocation(LOCATION_HAND)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local atk=e:GetLabel()
    if Duel.SpecialSummon(c,0,tp,tp,false,true,POS_FACEUP)~=0 then
        c:CompleteProcedure()
        if atk and atk>0 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            c:RegisterEffect(e1)
        end
    end
end

function s.thcon(e,tp)
    local c=e:GetHandler()
    return c:GetAttack()~=c:GetBaseAttack()
end

function s.thfilter1(c)
    return c:IsCode(65200230) and c:IsAbleToHand()
end
function s.thfilter2(c)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end

    local gy=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_ZOMBIE)
    local types={}
    local tc=gy:GetFirst()
    while tc do
        types[tc:GetCode()]=true
        tc=gy:GetNext()
    end
    local count=0
    for _ in pairs(types) do count=count+1 end

    if count>=4 then
        if Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
            if #g2>0 then
                Duel.SendtoHand(g2,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g2)
            end
        end
    end
end