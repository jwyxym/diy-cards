-- 鬼八仙·何仙姑 (ID:99849219)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,99849227)  

	-- ① 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e1_sp=e1:Clone()
	e1_sp:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1_sp)

	-- ② 
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_STEP_END+TIMING_BATTLE_END)
	e3:SetCountLimit(1,id+10000)
	e3:SetCondition(s.spcon3)  
	e3:SetTarget(s.sptg3)
	e3:SetOperation(s.spop3) 
	c:RegisterEffect(e3)
end

-- ========== ① ==========
function s.discard_filter(c)
	return c:IsCode(99849227) or aux.IsCodeListed(c,99849227)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.discard_filter, tp, LOCATION_HAND, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, nil, 1, tp, LOCATION_HAND)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()


	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, s.discard_filter, tp, LOCATION_HAND, 0, 1, 1, nil)
	if #g>0 then
		Duel.SendtoGrave(g, REASON_EFFECT)
	else
		return  
	end

   
	local ag=Duel.GetMatchingGroup(function(c) return c:IsFaceup() and c:IsAttackPos() end, tp, 0, LOCATION_MZONE, nil)
	for tc in aux.Next(ag) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(0)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end


	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_OATH)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1,0)
	e3:SetTarget(function(e, sc)
		return not sc:IsRace(RACE_ZOMBIE)
	end)
	e3:SetReset(0)  
	Duel.RegisterEffect(e3, tp)
end

-- ========== ② ==========
function s.spcon3(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	if not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) then return false end
	if Duel.GetTurnPlayer()==tp then return true end
	return Duel.GetMatchingGroupCount(Card.IsCode, tp, LOCATION_GRAVE, 0, nil, 99849227)>=3
end

function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- ① 
	if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)==0 then return end

	-- ② 
	local g=Duel.GetMatchingGroup(function(tc) return tc:IsFaceup() and tc:IsRace(RACE_ZOMBIE) end, tp, LOCATION_MZONE, 0, nil)
	for tc in aux.Next(g) do
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(800)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END, 2)
		tc:RegisterEffect(e2)
	end

	-- ③ 
	if Duel.IsExistingMatchingCard(function(tc) return tc~=c and tc:IsOnField() end, tp, LOCATION_ONFIELD, 0, 1, nil)
		and Duel.SelectYesNo(tp, aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp, function(tc) return tc~=c and tc:IsOnField() end, tp, LOCATION_ONFIELD, 0, 1, 1, nil)
		if #dg>0 then
			Duel.Destroy(dg, REASON_EFFECT)
		end
	end
end