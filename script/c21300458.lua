--苍炎之灾厄龙血池
local this,id,ofs=GetID()
function this.initial_effect(c)
    aux.EnablePendulumAttribute(c,false)
    aux.AddSynchroMixProcedure(c,this.matfilter1,nil,nil,this.matfilter2,1,99)
	c:EnableReviveLimit()
	local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(this.setcon)
	e2:SetTarget(this.settg)
	e2:SetOperation(this.setop)
	c:RegisterEffect(e2)
	aux.EnableChangeCode(c,21300422,LOCATION_MZONE+LOCATION_GRAVE)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(this.con)
    e1:SetCost(this.cost)
    e1:SetTarget(this.tg)
    e1:SetOperation(this.op)
    c:RegisterEffect(e1)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(this.pencon)
	e5:SetTarget(this.pentg)
	e5:SetOperation(this.penop)
	c:RegisterEffect(e5)
end
function this.matfilter1(c,scard)
    return c:IsRace(RACE_WYRM) and c:IsTuner(scard) or c:IsAttribute(ATTRIBUTE_FIRE)
end
function this.matfilter2(c,scard)
    return c:IsRace(RACE_WYRM) and c:IsNotTuner(scard)
end
function this.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_PZONE) and c:IsPreviousControler(tp)
end
function this.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(this.cfilter,1,nil,tp)
end
function this.filter(c,e,tp)
	return c:IsSetCard(0x678) and c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function this.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
    and Duel.GetLocationCountFromEx(tp)>0 end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function this.setop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCountFromEx(tp)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectMatchingCard(this.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    if tc then Duel.SpecialSummon(tc,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP) end
end
function this.costfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x678) and c:IsAbleToDeckAsCost()
end
function this.tgfilter(c)
    return c:IsSetCard(0x678) and c:IsAbleToGrave()
end
function this.con(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function this.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.costfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local tc=Duel.SelectMatchingCard(tp,this.costfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    Duel.SendtoDeck(tc,tp,LOCATION_DECKSHF,REASON_COST)
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,this.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
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
