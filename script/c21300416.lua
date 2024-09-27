--苍炎造访者 于内托纳
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),4,2,nil,nil,99)
	c:EnableReviveLimit()
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_PZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(this.spcon)
    e1:SetTarget(this.sptg)
    e1:SetOperation(this.spop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetTarget(this.dtg)
    e2:SetOperation(this.dop)
    c:RegisterEffect(e2)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(this.pencon)
	e5:SetTarget(this.pentg)
	e5:SetOperation(this.penop)
	c:RegisterEffect(e5)
end
function this.cfilter(c)
    return c:IsSetCard(0x678) and c:GetOriginalType()&(TYPE_MONSTER+TYPE_PENDULUM)>0
end
function this.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(this.cfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	if chk==0 then return tc and Duel.GetMZoneCount(tp)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	local fc=Duel.GetFirstTarget()
	if tc and Duel.GetMZoneCount(tp)>0
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
            Duel.BreakEffect()
            Duel.Destroy(c,REASON_EFFECT)
	end
end
function this.dtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsOnField() end
    if chk==0 then
        return c:CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
    end
    local dt=Duel.GetTargetCount(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    local ct=c:RemoveOverlayCard(tp,1,dt,REASON_COST)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function this.dop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.Destroy(g,REASON_EFFECT)
end
function this.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
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
