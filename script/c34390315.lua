--拉比林斯迷宫终局魅惑
function c34390315.initial_effect(c)
	--sset
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34390315,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetCountLimit(1,34390315)
	e1:SetCondition(c34390315.sccon)
	e1:SetTarget(c34390315.sctg)
	e1:SetOperation(c34390315.scop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34390315,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,34390315+1)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c34390315.sptg)
	e2:SetOperation(c34390315.spop)
	c:RegisterEffect(e2)
end
--sset
function c34390315.setfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSetCard(0x17e) and c:IsSSetable()
end
function c34390315.tfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
function c34390315.dncheck(g)
	return g:GetClassCount(Card.GetCode)==#g and g:IsExists(c34390315.setfilter,1,nil)
end
function c34390315.sccon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return (Duel.GetTurnPlayer()~=tp and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
function c34390315.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c34390315.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function c34390315.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(34390315,3))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e0:SetCode(EFFECT_CANNOT_ACTIVATE)
	e0:SetTargetRange(1,0)
	e0:SetValue(c34390315.aclimit)
	Duel.RegisterEffect(e0,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	if ft>=5 then ft=5 end
	local g=Duel.GetMatchingGroup(c34390315.tfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=g:SelectSubGroup(tp,c34390315.dncheck,false,ft,ft)
		if sg:GetCount()>0 then
			Duel.SSet(tp,sg)
			local tc=sg:GetFirst()
			while tc do
			   if tc then
					Duel.Damage(1-tp,100,REASON_EFFECT)
					tc:RegisterFlagEffect(34390315,RESET_EVENT+RESETS_STANDARD,0,1,34390315)
					if tp~=Duel.GetTurnPlayer() and Duel.GetAttacker()~=nil and Duel.GetAttackTarget()==nil then
						Duel.Damage(tp,100,REASON_EFFECT) 
						local e1=Effect.CreateEffect(c)
						e1:SetDescription(aux.Stringid(34390315,2))
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
						e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						tc:RegisterEffect(e1)
					end
				end
				tc=sg:GetNext()
			end
		end
	end
end
function c34390315.aclimit(e,re,tp)
	return re:GetHandler():GetFlagEffectLabel(34390315)==nil and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP)
end
--spsummon
function c34390315.spfilter(c,e,tp)
	return c:IsSetCard(0x17e) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c34390315.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c34390315.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function c34390315.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c34390315.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
