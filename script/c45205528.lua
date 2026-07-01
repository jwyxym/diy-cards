---山铜的封魔财宝
--卡密ID: 45205528

local s,id=GetID()

function s.initial_effect(c)
    aux.AddCodeList(c, 48179391)
    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id+100)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+200)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    -- 怪兽区
    local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
    local tc=g:GetFirst()
    while tc do
        if tc:IsFaceup() and aux.IsCodeOrListed(tc,48179391) then
            return true
        end
        tc=g:GetNext()
    end
    -- 魔陷区
    g=Duel.GetFieldGroup(tp,LOCATION_SZONE,0)
    tc=g:GetFirst()
    while tc do
        if tc:IsFaceup() and aux.IsCodeOrListed(tc,48179391) then
            return true
        end
        tc=g:GetNext()
    end
    -- 场地区
    local fzc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
    if fzc and fzc:IsFaceup() and aux.IsCodeOrListed(fzc,48179391) then
        return true
    end
    return false
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then
        local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
        if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
        return ft>0 and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_DECK)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
    
    local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
    if ft<=0 then return end
    
    local g=Duel.GetMatchingGroup(function(c) return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(tc) end, tp, LOCATION_DECK, 0, nil)
    if g:GetCount()==0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    local sc=g:Select(tp,1,1,nil):GetFirst()
    if sc then
        Duel.Equip(tp,sc,tc)
    end
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function s.thfilter(c)
    return c:IsAbleToHand() and aux.IsCodeOrListed(c,48179391)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end