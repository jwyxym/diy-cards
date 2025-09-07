--希望机 升华型·双极
function c31000506.initial_effect(c)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c31000506.lvtg)
	e1:SetOperation(c31000506.lvop)
	c:RegisterEffect(e1)
	local e11=e1:Clone()
	e11:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e11)
	--
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,31000506)
	e2:SetCondition(c31000506.spcon)
	e2:SetTarget(c31000506.sptg)
	e2:SetOperation(c31000506.spop)
	c:RegisterEffect(e2)
end
function c31000506.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetLevel()>0 end
end
function c31000506.lvfilter(c)
	return c:IsLevelAbove(1) and c:IsFaceup()
end
function c31000506.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or c:IsFacedown() then return end
	local down=c:IsLevelAbove(4)
	local lv=aux.SelectFromOptions(tp,{true,aux.Stringid(31000506,0),3},{down,aux.Stringid(31000506,1),-3})
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(lv)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	Duel.BreakEffect()
	local b1=Duel.IsExistingMatchingCard(c31000506.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil)
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(31000506,2)},
		{b2,aux.Stringid(31000506,3)},
		{true,aux.Stringid(31000506,4)})
	if op==1 then
		local g=Duel.GetMatchingGroup(c31000506.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local tc=g:Select(tp,1,1,nil):GetFirst()
			local down=tc:IsLevelAbove(2)
			local op2=aux.SelectFromOptions(tp,{true,aux.Stringid(31000506,0)},{down,aux.Stringid(31000506,1)})
			local slv=tc:GetLevel()
			local lv2=0
			if op2==1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
				lv2=Duel.AnnounceLevel(tp,1,2)
			elseif op2==2 then
				Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
				lv2=Duel.AnnounceLevel(tp,1,math.min(slv-1,2))*-1
			end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetValue(lv2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			tc:RegisterEffect(e1)
		end
	elseif op==2 then
		local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
		if g:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			Duel.SynchroSummon(tp,sg:GetFirst(),nil)
		end
	end
end
function c31000506.cfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAttribute(0x30) and c:IsFaceupEx()
end
function c31000506.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c31000506.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function c31000506.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31000506.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c31000506.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function c31000506.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end