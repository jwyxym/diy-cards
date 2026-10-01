--命运女郎共鸣
local s,id,o=GetID()
function s.initial_effect(c)

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


function s.cond(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	if ph~=PHASE_MAIN1 and ph~=PHASE_MAIN2 then return false end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return not g:IsExists(function(c) return c:IsSetCard(0x31) and c:IsType(TYPE_SYNCHRO) end,1,nil)
end

function s.starfilter(c)
	return c:IsCode(99848840) and c:IsAbleToHand()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.starfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.starfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g1:GetCount()==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc1=g1:Select(tp,1,1,nil):GetFirst()
	if not tc1 then return end
	if Duel.SendtoHand(tc1,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,tc1)
	
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(function(c)
			return c:IsSetCard(0x31) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		end),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
		if g2:GetCount()>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tc2=g2:Select(tp,1,1,nil):GetFirst()
			if tc2 then
				Duel.SendtoHand(tc2,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tc2)
			end
		end
	end
	
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x31)
end


function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_END and Duel.GetTurnPlayer()==tp
end


function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end


function s.lvop(e,tp,eg,ep,ev,re,r,rp)

	local g=Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
	local tc=g:GetFirst()
	while tc do
	 
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end