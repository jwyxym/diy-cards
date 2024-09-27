--诺艾尔 整理时刻
function c44100480.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--splimit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44100480.splimit)
	c:RegisterEffect(e1)
	--SpecialSummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44100480,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,44100480)
	e2:SetCondition(c44100480.spcon)
	e2:SetCost(c44100480.spcost)
	e2:SetTarget(c44100480.sptg)
	e2:SetOperation(c44100480.spop)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(44100480,ACTIVITY_SPSUMMON,c44100480.counterfilter)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44100480,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,44110480)
	e3:SetCost(c44100480.srcost)
	e3:SetTarget(c44100480.srtg)
	e3:SetOperation(c44100480.srop)
	c:RegisterEffect(e3)
	--to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(44100480,3))
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_EXTRA)
	e4:SetCountLimit(1,44110480)
	e4:SetCondition(c44100480.thcon)
	e4:SetTarget(c44100480.thtg)
	e4:SetOperation(c44100480.thop)
	c:RegisterEffect(e4)
end
function c44100480.counterfilter(c)
	return c:IsSetCard(0x44a)
end
function c44100480.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0x44a) and bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
function c44100480.pcfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
function c44100480.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(c44100480.pcfilter,tp,LOCATION_MZONE,0,1,nil) 
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=2
end
function c44100480.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(44100480,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c44100480.splimit2)
	Duel.RegisterEffect(e1,tp)
end
function c44100480.splimit2(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x44a)
end
function c44100480.spfilter(c,e,tp)
	return c:IsSetCard(0x44a) and c:IsType(TYPE_MONSTER) and c:IsDefenseBelow(2000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c44100480.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c44100480.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	local rg=Duel.GetDecktopGroup(tp,2)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,2,0,0)
end
function c44100480.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c44100480.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.BreakEffect()
		local rg=Duel.GetDecktopGroup(tp,2)
		Duel.DisableShuffleCheck()
		Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
	end
end
function c44100480.srcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function c44100480.penfilter(c)
	return c:IsSetCard(0x44a) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c44100480.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		and Duel.IsExistingMatchingCard(c44100480.penfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c44100480.srop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,c44100480.penfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
		if (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
			and c:IsRelateToEffect(e) and c:IsFaceup()
			and Duel.SelectEffectYesNo(tp,c,aux.Stringid(44100480,2)) then
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
function c44100480.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup()
end
function c44100480.thdesfilter(c)
	return c:IsSetCard(0x44a) and c:IsFaceup()
end
function c44100480.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and c44100480.thdesfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c44100480.thdesfilter,tp,LOCATION_ONFIELD,0,1,c)
		and c:IsAbleToHand() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c44100480.thdesfilter,tp,LOCATION_ONFIELD,0,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function c44100480.thfilter(c)
	return c:IsSetCard(0x44a) and c:IsAbleToHand()
end
function c44100480.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		local g=Duel.GetMatchingGroup(c44100480.thfilter,tp,LOCATION_PZONE,0,nil)
		if c:IsLocation(LOCATION_HAND) and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(44100480,4)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
		end
	end
end
