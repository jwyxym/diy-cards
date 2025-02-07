--梦想大千宇宙
function c20050005.initial_effect(c)
	aux.AddCodeList(c,19000032)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,20050005+EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(c20050005.activate)
	c:RegisterEffect(e0)
	--reduce tribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20050005,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCondition(c20050005.ntcon)
	e1:SetTarget(c20050005.nttg)
	c:RegisterEffect(e1)
	--summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20050005,2))
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,86239174)
	e3:SetTarget(c20050005.sumtg)
	e3:SetOperation(c20050005.sumop)
	c:RegisterEffect(e3)
end
function c20050005.filter(c)
	return c:IsCode(20050007) or c:IsCode(20050008) and c:IsAbleToHand()
end
function c20050005.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c20050005.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(20050005,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c20050005.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c20050005.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ILLUSION)
end
function c20050005.sumfilter(c)
	return ((c:IsRace(RACE_ILLUSION) and c:IsAttack(600) and c:IsDefense(600)) or c:IsCode(19000032)) and c:IsSummonable(true,nil)
end
function c20050005.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20050005.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function c20050005.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,c20050005.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end