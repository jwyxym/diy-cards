local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,99849227)

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DESTROY)
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

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_STEP_END+TIMING_BATTLE_END)
	e2:SetCountLimit(1,id+10000)
	e2:SetCondition(s.spcon3)
	e2:SetTarget(s.sptg3)
	e2:SetOperation(s.spop3)
	c:RegisterEffect(e2)
end

function s.th_filter(c)
	return c:IsCode(99849227)
end
function s.has_th_target(tp)
	return Duel.IsExistingMatchingCard(s.th_filter,tp,LOCATION_DECK,0,1,nil)
end
function s.destroy_filter(c)
	return c:IsType(TYPE_MONSTER)
end
function s.has_destroy_target(tp)
	return Duel.IsExistingMatchingCard(s.destroy_filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.sumlimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.has_th_target(tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	if s.has_destroy_target(tp) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
	end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if not s.has_th_target(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.th_filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()==0 then return end
	if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end

	if s.has_destroy_target(tp) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.destroy_filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if dg:GetCount()>0 then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end

	local e_limit=Effect.CreateEffect(e:GetHandler())
	e_limit:SetType(EFFECT_TYPE_FIELD)
	e_limit:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e_limit:SetDescription(aux.Stringid(id,2))
	e_limit:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e_limit:SetTargetRange(1,0)
	e_limit:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e_limit,tp)
end

function s.zombie_filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
function s.other_card_filter(c, exc)
	return c~=exc and c:IsOnField()
end
function s.spcon3(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	if not (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) then return false end
	if Duel.GetTurnPlayer()~=tp then return false end
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_GRAVE) then return false end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if g:IsExists(function(tc) return not tc:IsRace(RACE_ZOMBIE) end,1,nil) then return false end
	return true
end
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	if Duel.IsExistingMatchingCard(s.zombie_filter,tp,LOCATION_MZONE,0,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,0,tp,0)
	end
	if Duel.IsExistingMatchingCard(s.other_card_filter,tp,LOCATION_ONFIELD,0,1,nil,c) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
	end
end
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local g=Duel.GetMatchingGroup(s.zombie_filter,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(800)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
	end
	if Duel.IsExistingMatchingCard(s.other_card_filter,tp,LOCATION_ONFIELD,0,1,nil,c)
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,s.other_card_filter,tp,LOCATION_ONFIELD,0,1,1,nil,c)
		if dg:GetCount()>0 then
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end