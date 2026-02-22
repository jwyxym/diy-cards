--
function c19990049.initial_effect(c)
	c:SetSPSummonOnce(19990049)
	c:SetUniqueOnField(1,0,19990049)
	--xyz summon
	aux.AddXyzProcedure(c,nil,12,2,c19990049.ovfilter,aux.Stringid(19990049,0),99,c19990049.xyzop)
	c:EnableReviveLimit()
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	--destroy replace
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EFFECT_DESTROY_REPLACE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetTarget(c19990049.dreptg)
	e0:SetOperation(c19990049.drepop)
	c:RegisterEffect(e0)
	--material1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19990049,2))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c19990049.xyzmtg)
	e1:SetOperation(c19990049.xyzmop)
	c:RegisterEffect(e1)
	--pendulum
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19990049,4))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c19990049.pencon)
	e2:SetTarget(c19990049.pentg)
	e2:SetOperation(c19990049.penop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19990049,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,19990049)
	e3:SetCost(c19990049.spscost)
	e3:SetTarget(c19990049.spstg)
	e3:SetOperation(c19990049.spsop)
	c:RegisterEffect(e3)
	--material2
	local custom_code1=aux.RegisterMergedDelayedEvent_ToSingleCard(c,19990049,EVENT_RELEASE)
	local custom_code2=aux.RegisterMergedDelayedEvent_ToSingleCard(c,19990049,EVENT_REMOVE)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetDescription(aux.Stringid(19990049,3))
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(custom_code1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c19990049.thcon1)
	e4:SetOperation(c19990049.matop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(custom_code2)
	e5:SetCondition(c19990049.thcon2)
	c:RegisterEffect(e5)
end
c19990049.pendulum_level=12
function c19990049.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function c19990049.drepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
function c19990049.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb29) and c:IsType(TYPE_XYZ+TYPE_SYNCHRO+TYPE_FUSION) and (c:IsLevelAbove(8) or c:IsRankAbove(8)) and not c:IsCode(19990049)
end
function c19990049.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,19990049)==0 end
	Duel.RegisterFlagEffect(tp,19990049,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function c19990049.xyzmfilter(c)
	return c:IsSetCard(0xb29,0xb30) and c:IsCanOverlay()
end
function c19990049.xyzmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(c19990049.xyzmfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
end
function c19990049.xyzmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local g=Duel.SelectMatchingCard(tp,c19990049.xyzmfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,c,nil)
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
function c19990049.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
end
function c19990049.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function c19990049.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c19990049.spsfilter(c,tp)
	return c:IsSetCard(0xb29) and Duel.GetMZoneCount(tp,c)>0
end
function c19990049.spscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c19990049.spsfilter,4,REASON_COST,true,e,tp) end
	local g=Duel.SelectReleaseGroupEx(tp,c19990049.spsfilter,4,4,REASON_COST,true,e,tp)
	Duel.Release(g,REASON_COST)
end
function c19990049.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990049.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function c19990049.cfilter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp) and c:IsSetCard(0xb29)
end
function c19990049.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19990049.cfilter1,1,nil,tp)
end
function c19990049.cfilter2(c,tp)
	return c:IsFaceup() and c:IsPreviousControler(tp) and c:IsSetCard(0xb29,0xb30)
end
function c19990049.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19990049.cfilter2,1,nil,tp)
end
function c19990049.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsType(TYPE_XYZ) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mg=Duel.SelectMatchingCard(tp,Card.IsCanOverlay,tp,LOCATION_REMOVED+LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_REMOVED+LOCATION_GRAVE+LOCATION_ONFIELD,1,1,e:GetHandler())
	if #mg>0 then
		Duel.Overlay(c,mg)
	end
end