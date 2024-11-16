--
function c19990027.initial_effect(c)
	c:SetSPSummonOnce(19990027)
	--xyz summon
	aux.AddXyzProcedure(c,nil,8,2,c19990027.ovfilter,aux.Stringid(19990027,0),99,c19990027.xyzop)
	c:EnableReviveLimit()
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	--destroy replace
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EFFECT_DESTROY_REPLACE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetTarget(c19990027.dreptg)
	e0:SetOperation(c19990027.drepop)
	c:RegisterEffect(e0)
	--material1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990027,2))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c19990027.xyzmtg)
	e1:SetOperation(c19990027.xyzmop)
	c:RegisterEffect(e1)
	--pendulum
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19990027,4))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c19990027.pencon)
	e2:SetTarget(c19990027.pentg)
	e2:SetOperation(c19990027.penop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19990027,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,19990027)
	e3:SetCost(c19990027.spcost)
	e3:SetTarget(c19990027.sptg)
	e3:SetOperation(c19990027.spop)
	c:RegisterEffect(e3)
	--material2
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,19990027+100)
	e4:SetTarget(c19990027.target)
	e4:SetOperation(c19990027.operation)
	c:RegisterEffect(e4)
end
c19990027.pendulum_level=8
function c19990027.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function c19990027.drepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
function c19990027.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb29) and c:IsType(TYPE_XYZ+TYPE_SYNCHRO+TYPE_LINK) and not c:IsCode(19990027)
end
function c19990027.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,19990027)==0 end
	Duel.RegisterFlagEffect(tp,19990027,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c19990027.xyzmfilter(c)
	return c:IsSetCard(0xb29,0xb30) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsCanOverlay()
end
function c19990027.xyzmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(c19990027.xyzmfilter,tp,LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_GRAVE,0,1,e:GetHandler()) end
end
function c19990027.xyzmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,c19990027.xyzmfilter,tp,LOCATION_REMOVED+LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,c,e)
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
function c19990027.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
end
function c19990027.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function c19990027.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c19990027.cfilter(c)
	return c:IsSetCard(0xb30) and c:IsAbleToRemoveAsCost()
end
function c19990027.mzfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
function c19990027.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(c19990027.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	if chk==0 then return ft>-4 and rg:GetCount()>1 and (ft>0 or rg:IsExists(c19990027.mzfilter,ct,nil)) end
	local g=nil
	if ft>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=rg:Select(tp,4,4,nil)
	elseif ft==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=rg:FilterSelect(tp,c19990027.mzfilter,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=rg:Select(tp,1,1,g:GetFirst())
		g:Merge(g2)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=rg:FilterSelect(tp,c19990027.mzfilter,4,4,nil)
	end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c19990027.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990027.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c19990027.filter(c)
	return c:IsCanOverlay()
end
function c19990027.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and c19990027.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(c19990027.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	Duel.SelectTarget(tp,c19990027.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,e:GetHandler())
end
function c19990027.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			Duel.SendtoGrave(og,REASON_RULE)
		end
		Duel.Overlay(c,Group.FromCards(tc))
	end
end