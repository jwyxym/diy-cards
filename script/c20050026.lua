--梦想集邮
function c20050026.initial_effect(c)
	c:SetUniqueOnField(1,0,20050026)
	aux.AddCodeList(c,19000032)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,20050026+EFFECT_COUNT_CODE_OATH)
	e0:SetOperation(c20050026.activate)
	c:RegisterEffect(e0)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c20050026.thcon)
	e2:SetTarget(c20050026.thtg)
	e2:SetOperation(c20050026.thop)
	c:RegisterEffect(e2)
	--reduce tribute
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20050026,2))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c20050026.ntcon)
	e3:SetTarget(c20050026.nttg)
	c:RegisterEffect(e3)
end
function c20050026.filter(c)
	return c:IsCode(20050021) or c:IsCode(20050006) and c:IsAbleToHand()
end
function c20050026.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c20050026.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(20050026,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c20050026.thtfilter(c,tp)
	return c:IsFaceup() and c:IsPreviousControler(tp) and (c:IsCode(19000032) or (aux.IsCodeListed(c,19000032) and c:IsType(TYPE_SPELL+TYPE_TRAP)))
end
function c20050026.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c20050026.thtfilter,1,nil,tp)
end
function c20050026.thfilter(c)
	return (c:IsRace(RACE_ILLUSION) and c:IsAttack(600) and c:IsDefense(600)) and c:IsAbleToHand()
end
function c20050026.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20050026.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c20050026.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c20050026.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,e:GetHandler())
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c20050026.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function c20050026.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ILLUSION)
end
