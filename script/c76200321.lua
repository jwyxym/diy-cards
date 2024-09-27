--王之氏族 诺克蕾娜
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.EnablePendulumAttribute(c)
    aux.AddCodeList(c,76200312)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(this.thtg)
    e1:SetOperation(this.thop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(this.spcon)
    e2:SetTarget(this.sptg)
    e2:SetOperation(this.spop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+2)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetTarget(this.atg)
    e3:SetOperation(this.aop)
    c:RegisterEffect(e3)
end
function this.thfilter(c)
    return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
function this.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and this.thfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(this.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,aux.NecroValleyFilter(this.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function this.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local c=e:GetHandler()
    if not tc:IsRelateToEffect(e) then return end
    if Duel.SendtoHand(tc,tp,REASON_EFFECT)>0 then
        if c:IsRelateToEffect(e) then
            Duel.BreakEffect()
            Duel.Destroy(c,REASON_EFFECT)
        end
        local e3=Effect.CreateEffect(c)
	    e3:SetType(EFFECT_TYPE_FIELD)
	    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	    e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	    e3:SetTargetRange(1,0)
        e3:SetLabel(tc:GetCode())
	    e3:SetValue(this.aclimit)
	    e3:SetReset(RESET_PHASE+PHASE_END)
	    Duel.RegisterEffect(e3,tp)
    end
end
function this.aclimit(e,re,tp)
	local c=re:GetHandler()
	return e:GetLabel()==c:GetCode()
end
function this.spfilter(c)
    return c:IsCode(76200312) and c:IsFaceup()
end
function this.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsExistingMatchingCard(this.spfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_HAND)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
function this.atg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function this.aop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) or not c:IsRelateToEffect(e) then return end
    local preatk=tc:GetAttack()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(-300)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetValue(300)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
    tc:RegisterEffect(e2)
    if preatk~=0 and c:IsAttack(0) then Duel.Destroy(c,REASON_EFFECT) end
end
