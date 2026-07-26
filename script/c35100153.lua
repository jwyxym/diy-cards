--异质绝望 蠢动的目光
function c35100153.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35100153,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35100153)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c35100153.target)
	e1:SetOperation(c35100153.activate)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35100153,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,35100156)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c35100153.settg)
	e2:SetOperation(c35100153.setop)
	c:RegisterEffect(e2)
end
function c35100153.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		Duel.IsPlayerCanSpecialSummonMonster(tp,35100153,0,TYPES_NORMAL_TRAP_MONSTER,1800,0,3,RACE_WARRIOR,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c35100153.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xa91) and c:IsType(TYPE_EFFECT)
end
function c35100153.sdfilter(c)
	return c:IsFaceup() and c:IsAbleToDeck()
end
function c35100153.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,35100153,0,TYPES_NORMAL_TRAP_MONSTER,1800,0,3,RACE_WARRIOR,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_NORMAL+TYPE_TRAP)
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0
		and Duel.IsExistingMatchingCard(c35100153.filter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(c35100153.sdfilter,tp,0,LOCATION_ONFIELD,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(35100153,2)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,c35100153.sdfilter,tp,0,LOCATION_ONFIELD,1,1,1,nil)
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		if tc then
			Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
function c35100153.setfilter(c)
	return c:IsSetCard(0xa91) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
function c35100153.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c35100153.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c35100153.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c35100153.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end