--
function c20020027.initial_effect(c)
	c:SetUniqueOnField(1,0,20020027)
	--xyz summon
	aux.AddXyzProcedure(c,c20020027.mfilter,8,2,c20020027.ovfilter,aux.Stringid(20020027,0),2,c20020027.xyzop)
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
	e2:SetDescription(aux.Stringid(20020027,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1)
	e2:SetCost(c20020027.cpcost)
	e2:SetTarget(c20020027.cptg)
	e2:SetOperation(c20020027.cpop)
	c:RegisterEffect(e2)
	--material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20020027,2))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c20020027.matcon)
	e3:SetTarget(c20020027.mattg)
	e3:SetOperation(c20020027.matop)
	c:RegisterEffect(e3)
end
function c20020027.mfilter(c)
	return c:IsSetCard(0xb35)
end
function c20020027.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb35) and (c:IsLevel(10) or c:IsRank(6))
end
function c20020027.cpfilter(c)
	return (c:GetType()==TYPE_TRAP and c:IsSetCard(0xb35)) or (c:IsCode(20020005) and not c:IsType(TYPE_MONSTER)) and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(false,true,false)
end
function c20020027.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
function c20020027.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(c20020027.cpfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
	end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c20020027.cpfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	Duel.ClearOperationInfo(0)
end
function c20020027.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
function c20020027.matcon(e)
	return Duel.IsExistingMatchingCard(Card.IsCode,e:GetHandlerPlayer(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,20020005)
end
function c20020027.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function c20020027.mfilter(c)
	return c:IsSetCard(0xb35) and c:IsCanOverlay()
end
function c20020027.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsPosition(LOCATION_MZONE) and c20020027.xyzfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c20020027.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(c20020027.mfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c20020027.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetChainLimit(c20020027.chlimit)
end
function c20020027.chlimit(e,ep,tp)
	return tp==ep
end
function c20020027.matop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,c20020027.mfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.Overlay(tc,g)
		end
	end
end