--吸血鬼幼领主
function c11771425.initial_effect(c)
	-- 卡组送墓
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11771425,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,11771425)
	e1:SetCost(c11771425.cost1)
	e1:SetTarget(c11771425.tg1)
	e1:SetOperation(c11771425.op1)
	c:RegisterEffect(e1)
	-- 双召战吼
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11771425,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11771426)
	e2:SetTarget(c11771425.tg2)
	e2:SetOperation(c11771425.op2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
    -- 特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetOperation(c11771425.op3)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(11771425,2))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c11771425.con4)
	e5:SetTarget(c11771425.tg4)
	e5:SetOperation(c11771425.op4)
	c:RegisterEffect(e5)
	-- 自肃相关
	Duel.AddCustomActivityCounter(11771425,ACTIVITY_SUMMON,c11771425.counterfilter)
	Duel.AddCustomActivityCounter(11771425,ACTIVITY_SPSUMMON,c11771425.counterfilter)
end
-- 自肃
function c11771425.counterfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- 1
function c11771425.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(c11771425.filter1,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c11771425.filter1,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_COST)
end
function c11771425.filter1(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGraveAsCost()
end
function c11771425.filter11(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end
function c11771425.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11771425.filter11,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c11771425.op1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c11771425.filter11,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 2
function c11771425.filter2(c)
	return c:IsSetCard(0x8e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c11771425.sumfilter(c)
	return c:IsSetCard(0x8e) and c:IsSummonable(true,nil)
end
function c11771425.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c11771425.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c11771425.op2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11771425.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		if Duel.IsExistingMatchingCard(c11771425.sumfilter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(11771425,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
			local sg=Duel.SelectMatchingCard(tp,c11771425.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
			if sg:GetCount()>0 then
				Duel.Summon(tp,sg:GetFirst(),true,nil)
			end
		end
	end
end
-- 3
function c11771425.op3(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(11771401,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
function c11771425.con4(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(11771401)~=0
end
function c11771425.filter4(c,e,tp,rc,tid)
	return c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc and c:GetTurnID()==tid
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c11771425.tg4(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c11771425.filter4,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,e:GetHandler(),Duel.GetTurnCount()) end
	local g=Duel.GetMatchingGroup(c11771425.filter4,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c11771425.op4(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c11771425.filter4),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	local g=nil
	if tg:GetCount()>ft then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
