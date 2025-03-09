--饥饿棘花 莲陀罗
function c47700006.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,c47700006.mfilter1,c47700006.mfilter2,true)
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c47700006.splimit)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,47700006)
	e1:SetCondition(c47700006.condition)
	e1:SetTarget(c47700006.target)
	e1:SetOperation(c47700006.activate)
	c:RegisterEffect(e1)
	--attribute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(ATTRIBUTE_DARK)
	e2:SetCondition(c47700006.attrcon)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,47700006+1)
	e3:SetCondition(c47700006.descon)
	e3:SetTarget(c47700006.destg)
	e3:SetOperation(c47700006.desop)
	c:RegisterEffect(e3)
end
function c47700006.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end
function c47700006.mfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsFusionType(TYPE_PENDULUM) and c:IsRace(RACE_DRAGON+RACE_PLANT)
end
function c47700006.mfilter2(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsFusionType(TYPE_FUSION)
end
function c47700006.condition(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
function c47700006.filter(c)
	return c:IsType(TYPE_MONSTER)
end
function c47700006.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and c47700006.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c47700006.filter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c47700006.filter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil)
end
function c47700006.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e1:SetTarget(c47700006.distg)
		e1:SetLabelObject(tc)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVING)
		e2:SetCondition(c47700006.discon)
		e2:SetOperation(c47700006.disop)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		Duel.AdjustInstantly(tc)
		if not tc:IsLevelAbove(5) then
			local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_MZONE,nil)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(47700006,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local sg=g:Select(tp,1,1,nil)
				Duel.HintSelection(sg)
				Duel.SendtoGrave(sg,REASON_EFFECT)
			end
		end
	end
end
function c47700006.distg(e,c)
	local tc=e:GetLabelObject()
	return c:IsOriginalCodeRule(tc:GetOriginalCodeRule()) and (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0)
end
function c47700006.discon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
function c47700006.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function c47700006.attrcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c47700006.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function c47700006.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if chk==0 then return #dg>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
function c47700006.rmfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_FUSION) and c:IsAbleToRemove()
		and Duel.IsExistingMatchingCard(c47700006.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
function c47700006.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c47700006.desop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	if Duel.Destroy(dg,REASON_EFFECT)==0 then return end
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(c47700006.rmfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(47700006,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=g:Select(tp,1,1,nil)
		if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 and rg:GetFirst():IsLocation(LOCATION_REMOVED) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,c47700006.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #sg>0 then
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end