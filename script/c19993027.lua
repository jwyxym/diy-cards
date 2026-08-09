--
function c19993027.initial_effect(c)
	c:SetUniqueOnField(1,0,19993027)
	--xyz summon
	aux.AddXyzProcedure(c,c19993027.mfilter,8,2,c19993027.ovfilter,aux.Stringid(19993027,0),2,c19993027.xyzop)
	c:EnableReviveLimit()
	--spsummon limit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.xyzlimit)
	c:RegisterEffect(e1)
	--copy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19993027,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1)
	e2:SetCost(c19993027.cpcost)
	e2:SetTarget(c19993027.cptg)
	e2:SetOperation(c19993027.cpop)
	c:RegisterEffect(e2)
	--material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19993027,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c19993027.matcon)
	e3:SetTarget(c19993027.mattg)
	e3:SetOperation(c19993027.matop)
	c:RegisterEffect(e3)
end
function c19993027.mfilter(c)
	return c:IsSetCard(0xb35)
end
function c19993027.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb35) and (c:IsLevel(10) or c:IsRank(6))
end
function c19993027.cpfilter(c)
	return ((c:GetType()==0x4 and c:IsSetCard(0xb35)) or (c:IsCode(19993005) and not c:IsType(TYPE_MONSTER))) and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(false,true,false)~=nil
end
function c19993027.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c19993027.cpfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) and c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(19993027,3))
	local g=Duel.SelectMatchingCard(tp,c19993027.cpfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	local te=g:GetFirst():CheckActivateEffect(false,true,true)
	c19993027[Duel.GetCurrentChain()]=te
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c19993027.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local te=c19993027[Duel.GetCurrentChain()]
	if chkc then
		local tg=te:GetTarget()
		return tg(e,tp,eg,ep,ev,re,r,rp,0,true)
	end
	if chk==0 then return true end
	if not te then return end
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	Duel.ClearOperationInfo(0)
end
function c19993027.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=c19993027[Duel.GetCurrentChain()]
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function c19993027.matcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,19993005)
end
function c19993027.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function c19993027.mfilter(c)
	return c:IsSetCard(0xb35) and c:IsCanOverlay()
end
function c19993027.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsPosition(LOCATION_MZONE) and c19993027.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c19993027.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(c19993027.mfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c19993027.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetChainLimit(c19993027.chlimit)
end
function c19993027.chlimit(e,ep,tp)
	return tp==ep
end
function c19993027.matop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,c19993027.mfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.Overlay(tc,g)
		end
	end
end