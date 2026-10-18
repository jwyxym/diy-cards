local s,id=GetID()
local HOLY=0x474

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(2,id+100)
    e2:SetCondition(s.lvcon)
    e2:SetTarget(s.lvtg)
    e2:SetOperation(s.lvop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(2,id+100)
    e3:SetCondition(s.retcon)
    e3:SetTarget(s.rettg)
    e3:SetOperation(s.retop)
    c:RegisterEffect(e3)
end

function s.thfilter(c)
    return c:IsSetCard(HOLY)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
    local sg=g:Select(tp,1,1,nil)
    local tc=sg:GetFirst()

    local b1=tc:IsAbleToHand()
    local b2=tc:IsType(TYPE_SPELL+TYPE_TRAP) and tc:IsSSetable()

    if b1 and b2 then
        if Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        else
            Duel.SSet(tp,tc)
        end
    elseif b1 then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    elseif b2 then
        Duel.SSet(tp,tc)
    end
end

function s.lvfilter(c,tp)
    return c:IsControler(tp) and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK))
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.lvfilter,1,nil,tp)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) or not tc:IsFaceup() then return end
    
    local lv=tc:GetLevel()
    local rank=tc:GetRank()
    local addatk=0

    if rank>0 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_RANK)
        e1:SetValue(3)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 2)
        tc:RegisterEffect(e1)
        addatk=(rank+3)*300
    elseif lv>0 then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_LEVEL)
        e1:SetValue(3)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 2)
        tc:RegisterEffect(e1)
        addatk=(lv+3)*300
    else
        return 
    end

    if addatk>0 then
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetValue(addatk)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 2)
        tc:RegisterEffect(e2)
    end
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and re and re:IsActiveType(TYPE_MONSTER)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_GRAVE) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end