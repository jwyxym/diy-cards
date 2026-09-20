--通关拉比林斯迷宫的奖励
function c34390310.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34390310,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,34390310)
	e1:SetTarget(c34390310.target)
	e1:SetOperation(c34390310.activate)
	c:RegisterEffect(e1)
	--Trap activate in set turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34390310,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,34390310+1)
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c34390310.operation)
	c:RegisterEffect(e2)
end
--Activate
function c34390310.thfilter1(c,e,tp)
	if not (c:IsSetCard(0x17e) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(8)) then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
end
function c34390310.mfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(8)
end
function c34390310.thfilter2(c,e,tp)
	return c:IsSetCard(0x17e) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c34390310.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c34390310.thfilter2,tp,LOCATION_DECK,0,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then 
		return Duel.IsExistingMatchingCard(c34390310.thfilter1,tp,LOCATION_DECK,0,1,nil,e,tp) or (Duel.IsExistingMatchingCard(c34390310.mfilter,tp,LOCATION_MZONE,0,1,nil) and g:GetClassCount(Card.GetCode)>=2 and ft>1 and (not Duel.IsPlayerAffectedByEffect(tp,59822133))) 
	end
end
function c34390310.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c34390310.thfilter2,tp,LOCATION_DECK,0,nil,e,tp)
	local g8=Duel.GetMatchingGroup(c34390310.thfilter1,tp,LOCATION_DECK,0,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsExistingMatchingCard(c34390310.mfilter,tp,LOCATION_MZONE,0,1,nil) and g:GetClassCount(Card.GetCode)>=2 and ft>1 and (not Duel.IsPlayerAffectedByEffect(tp,59822133)) and Duel.SelectYesNo(tp,aux.Stringid(34390310,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	elseif g8:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local tc=g8:Select(tp,1,1,nil):GetFirst()
		local opt=0
		if not tc:IsAbleToHand() then
			opt=1
		elseif not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 then
			opt=0
		else
			opt=Duel.SelectOption(tp,1190,1152)
		end
		if opt==0 then
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
--Trap activate in set turn
function c34390310.operation(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(34390310,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetCountLimit(1)
	e1:SetTarget(c34390310.acttg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c34390310.acttg(e,c)
	return c:GetType()==TYPE_TRAP
end

