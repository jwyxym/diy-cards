--CH.099 《希望姬统龙传-爱尔比斯·德拉刻》
function c10100099.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),aux.NonTuner(Card.IsSynchroType,TYPE_SYNCHRO),2)
	c:EnableReviveLimit()
	--SpecialSummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10100099,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,10100099)
	e1:SetCost(c10100099.spcost)
	e1:SetTarget(c10100099.sptg1)
	e1:SetOperation(c10100099.spop1)
	c:RegisterEffect(e1)
	local e11=e1:Clone()
	e11:SetDescription(aux.Stringid(10100099,1))
	e11:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e11:SetTarget(c10100099.sptg2)
	e11:SetOperation(c10100099.spop2)
	c:RegisterEffect(e11)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10100099,2))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,10100099+1)
	e2:SetCondition(c10100099.discon)
	e2:SetTarget(c10100099.distg)
	e2:SetOperation(c10100099.disop)
	c:RegisterEffect(e2)
	
end
function c10100099.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function c10100099.tgfilter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x314) and c:IsType(0x1) or c:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS))
		and c:IsAbleToGrave() and Duel.GetLocationCountFromEx(tp,tp,c,TYPE_SYNCHRO)>0
end
function c10100099.spfilter1(c,e,tp)
	return c:IsSetCard(0x314) and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c10100099.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c10100099.tgfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(c10100099.spfilter1,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c10100099.spop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,c10100099.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(0x10) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,c10100099.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
function c10100099.spfilter2(c,e,tp)
	return c:IsSetCard(0xd10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c10100099.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c10100099.spfilter2,tp,0x30,0x30,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x30)
end
function c10100099.spop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c10100099.spfilter2),tp,0x30,0x30,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c10100099.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsExists(Card.IsOnField,1,nil,tp) and Duel.IsChainNegatable(ev)
end
function c10100099.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c10100099.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		if Duel.Destroy(eg,REASON_EFFECT)>0 then
			local g=Duel.GetMatchingGroup(aux.nzatk,tp,0,LOCATION_MZONE,nil)
				if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(10100099,3)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
				local tc=g:Select(tp,1,1,nil):GetFirst()
				if tc then
					Duel.BreakEffect()
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_SET_ATTACK_FINAL)
					e1:SetValue(0)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
				end
			end
		end
	end
end