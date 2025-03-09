--
function c19990026.initial_effect(c)
	c:SetSPSummonOnce(19990026)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),4,2,nil,nil,99)
	c:EnableReviveLimit()
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	--material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990026,2))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c19990026.xyztg)
	e1:SetOperation(c19990026.xyzop)
	c:RegisterEffect(e1)
	--pendulum
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19990026,4))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c19990026.pencon)
	e2:SetTarget(c19990026.pentg)
	e2:SetOperation(c19990026.penop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19990026,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,19990026)
	e3:SetCost(c19990026.spscost)
	e3:SetTarget(c19990026.spstg)
	e3:SetOperation(c19990026.spsop)
	c:RegisterEffect(e3)
	--negate
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCountLimit(1,19990026+100)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c19990026.discon)
	e4:SetCost(c19990026.discost)
	e4:SetTarget(c19990026.distg)
	e4:SetOperation(c19990026.disop)
	c:RegisterEffect(e4)
end
c19990026.pendulum_level=4
function c19990026.xyzfilter(c)
	return c:IsSetCard(0xb29,0xb30) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsCanOverlay()
end
function c19990026.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(c19990026.xyzfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,e:GetHandler()) end
end
function c19990026.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,c19990026.xyzfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,c,e)
		local tc=g:GetFirst()
		if tc then
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				Duel.SendtoGrave(og,REASON_RULE)
			end
			Duel.Overlay(c,tc)
		end
	end
end
function c19990026.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
end
function c19990026.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function c19990026.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c19990026.spsfilter(c,tp)
	return c:IsSetCard(0xb29) and Duel.GetMZoneCount(tp,c)>0
end
function c19990026.spscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c19990026.spsfilter,2,REASON_COST,true,e,tp) end
	local g=Duel.SelectReleaseGroupEx(tp,c19990026.spsfilter,2,2,REASON_COST,true,e,tp)
	Duel.Release(g,REASON_COST)
end
function c19990026.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990026.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function c19990026.discon(e,tp,eg,ep,ev,re,r,rp)
	local ex4=re:IsHasCategory(CATEGORY_DRAW)
	local ex5=re:IsHasCategory(CATEGORY_SEARCH)
	return (ex4 or ex5) and Duel.IsChainDisablable(ev)
end
function c19990026.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c19990026.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c19990026.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end