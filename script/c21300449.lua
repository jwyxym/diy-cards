--涬溟阁龙 曦月
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
    aux.AddSynchroMixProcedure(c,this.matfilter,nil,nil,aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),1,99)
    c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(this.pcost)
    e1:SetTarget(this.ptg)
    e1:SetOperation(this.pop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,id+1)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(this.tpcon)
    e2:SetTarget(this.tptg)
    e2:SetOperation(this.tpop)
    c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+2)
	e3:SetTarget(this.negtg)
	e3:SetOperation(this.negop)
	c:RegisterEffect(e3)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(this.pencon)
	e5:SetTarget(this.pentg)
	e5:SetOperation(this.penop)
	c:RegisterEffect(e5)
end
function this.matfilter(c,scard)
    return c:IsRace(RACE_WYRM) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsTuner(scard) or c:IsRace(RACE_WYRM)
end
function this.pfilter(c)
    return c:IsAbleToGraveAsCost() and c:IsSetCard(0x678) and c:IsType(TYPE_PENDULUM)
end
function this.pcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.pfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=Duel.SelectMatchingCard(tp,this.pfilter,tp,LOCATION_DECK,0,1,1,nil)
    Duel.SendtoGrave(tc,REASON_COST)
end
function this.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c) end
end
function this.pop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
    if tc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LSCALE)
		e1:SetValue(11)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_RSCALE)
		tc:RegisterEffect(e2)
    end
end
function this.tpfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_WYRM) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function this.tpcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function this.tptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.tpfilter,tp,LOCATION_EXTRA,0,1,nil) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) end
end
function this.tpop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local tc=Duel.SelectMatchingCard(tp,this.tpfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
    if tc and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
        Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
    end
end
function this.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function this.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end
function this.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup() and bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
function this.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function this.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
