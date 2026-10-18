--命运女郎共鸣
local s,id,o=GetID()
function s.initial_effect(c)
	-- ① 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_MAIN_END,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.cond)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

	-- ② 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+10000)
	e2:SetCondition(s.lvcon)
	e2:SetCost(s.lvcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end

-- =====================================



function s.synchro_filter(c)
	return c:IsFaceup() and c:IsSetCard(0x31) and c:IsType(TYPE_SYNCHRO)
end



function s.starfilter(c)
	return c:IsCode(99848840) and c:IsAbleToHand()
end


function s.thfilter(c)
	return c:IsSetCard(0x31) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end



function s.has_star_target(tp)
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.starfilter),
		tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
end



function s.has_th_target(tp)
	return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),
		tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
end



function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	if not c then return false end
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_SYNCHRO)
end

-- ==================== ① ===================


--
function s.cond(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	if ph~=PHASE_MAIN1 and ph~=PHASE_MAIN2 then return false end

	return not Duel.IsExistingMatchingCard(s.synchro_filter,tp,LOCATION_MZONE,0,1,nil)
end


function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return s.has_star_target(tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)

	if s.has_th_target(tp) then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end


function s.activate(e,tp,eg,ep,ev,re,r,rp)
 
	if not s.has_star_target(tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.starfilter),
		tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g1:GetCount()==0 then return end
	if Duel.SendtoHand(g1,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,g1)


	if s.has_th_target(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),
			tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if g2:GetCount()>0 then
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end
	end


	local e_limit=Effect.CreateEffect(e:GetHandler())
	e_limit:SetType(EFFECT_TYPE_FIELD)
	e_limit:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e_limit:SetDescription(aux.Stringid(id,3))
	e_limit:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e_limit:SetTargetRange(1,0)
	e_limit:SetTarget(s.splimit)
	e_limit:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e_limit,tp)
end

-- ==================== ② ====================


-- ②
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_END and Duel.GetTurnPlayer()==tp
end


-- ②
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return e:GetHandler():IsAbleToRemoveAsCost()
	end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end


function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end


-- ②
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,
		LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end