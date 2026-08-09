--不朽机骸 灵魂之核
function c31280126.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,31280126+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c31280126.activate)
	c:RegisterEffect(e1)
	--卡组送墓   
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31280126,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,31280126)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(c31280126.target)
	e2:SetOperation(c31280126.operation)
	c:RegisterEffect(e2)
	--魔陷盖放
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31280126,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(c31280126.condition1)
	e3:SetTarget(c31280126.target1)
	e3:SetOperation(c31280126.operation1)
	c:RegisterEffect(e3)
end   
function c31280126.filter(c)
	return c:IsSetCard(0xca2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c31280126.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c31280126.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(31280126,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c31280126.tgfilter(c)
	return c:IsSetCard(0xca2) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function c31280126.cfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and c:IsControler(tp) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsType(TYPE_FUSION)
end
function c31280126.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return eg:IsExists(c31280126.cfilter,1,nil,tp) and Duel.IsExistingMatchingCard(c31280126.tgfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function c31280126.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c31280126.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,nil,REASON_EFFECT)
	end
end
function c31280126.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c31280126.sfilter(c)
	return c:IsSetCard(0xca2) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() and not c:IsCode(31280126)
end
function c31280126.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c31280126.sfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c31280126.sfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,c31280126.sfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function c31280126.operation1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.SSet(tp,tc) end
end