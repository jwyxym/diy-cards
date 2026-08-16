--山铜幻镜
--卡密ID: 45205526

local s,id=GetID()

function s.initial_effect(c)
    aux.AddCodeList(c, 45205525)
    aux.AddCodeList(c, 48179391)
    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.filter(c)
    return c:IsCode(45205525) and c:IsType(TYPE_RITUAL)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
        if sg:GetCount()==0 then return false end
        local mg=Duel.GetMatchingGroup(Card.IsOnField,tp,LOCATION_MZONE,0,nil)
        local sum=0
        local tc=mg:GetFirst()
        while tc do
            sum=sum+tc:GetLevel()
            tc=mg:GetNext()
        end
        if sum<6 then return false end
        return true
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
    if sg:GetCount()==0 then return end
    local tc=sg:GetFirst()
    
    local mg=Duel.GetMatchingGroup(Card.IsOnField,tp,LOCATION_MZONE,0,nil)
    if mg:GetCount()==0 then return end
    
    local mat=Group.CreateGroup()
    local sum=0
    local list=mg:GetFirst()
    while sum<6 and list do
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        local g=mg:Select(tp,1,1,nil)
        if g:GetCount()==0 then return end
        local sc=g:GetFirst()
        mat:AddCard(sc)
        sum=sum+sc:GetLevel()
        mg:RemoveCard(sc)
        list=mg:GetFirst()
    end
    if sum<6 then return end
    
    tc:SetMaterial(mat)
    Duel.Release(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
    Duel.BreakEffect()
    
    if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,false,POS_FACEUP)>0 then
        tc:CompleteProcedure()
        tc:ResetEffect(EFFECT_UPDATE_ATTACK, RESET_EVENT+RESETS_STANDARD)
        local e1=Effect.CreateEffect(tc)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(s.atkval)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end

function s.atkval(e,c)
    local ct=Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)
    return ct*300
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function s.thfilter(c)
    return c:IsCode(48179391) and c:IsAbleToHand()
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