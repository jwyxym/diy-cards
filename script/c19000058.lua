--古代妖龙的冻结
function c19000058.initial_effect(c)
	c:SetUniqueOnField(1,0,19000058)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND)
	e0:SetDescription(aux.Stringid(19000058,0))
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,19000058+EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(c19000058.top)
	c:RegisterEffect(e0)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,19000058+100)
	e1:SetTarget(c19000058.target)
	e1:SetOperation(c19000058.activate)
	c:RegisterEffect(e1)
	--splimit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_ONFIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c19000058.splimit)
	c:RegisterEffect(e2)
end
function c19000058.tfilter(c,e,tp)
	return c:IsType(TYPE_SPELL) and (c:GetOriginalLevel()>0 and bit.band(c:GetOriginalRace(),0x3fffffff)~=0 and bit.band(c:GetOriginalAttribute(),0x7f)~=0) and c:IsAbleToHand() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function c19000058.top(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c19000058.tfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19000058,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c19000058.tgfilter(c,tp)
	return c:IsAbleToGrave() and c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(10) or c:IsLevel(11) or c:IsLevel(12)
end
function c19000058.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c19000058.tgfilter,tp,LOCATION_EXTRA,0,1,nil)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,19000058,0,TYPES_EFFECT_TRAP_MONSTER+TYPE_SYNCHRO,2500,2500,10,RACE_WYRM,ATTRIBUTE_WATER) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19000058.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c19000058.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,19000058,0,TYPES_EFFECT_TRAP_MONSTER+TYPE_SYNCHRO,2500,2500,10,RACE_WYRM,ATTRIBUTE_WATER) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_SPELL+TYPE_SYNCHRO)
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
function c19000058.splimit(e,c)
	return not (c:IsType(TYPE_SYNCHRO) and c:IsAttribute(ATTRIBUTE_LIGHT)) and c:IsLocation(LOCATION_EXTRA)
end