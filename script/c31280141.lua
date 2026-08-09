--永续的机械·尼古拉
function c31280141.initial_effect(c)
	aux.AddCodeList(c,31280142)
	--融合召唤
	aux.AddFusionProcMix(c,false,true,31280142,c31280141.fusfilter1,c31280141.fusfilter2)
	c:EnableReviveLimit()
	--特召代价
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_COST)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCost(c31280141.spcost)
	c:RegisterEffect(e1)
    --种族视为机械族
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_RACE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA)
	e2:SetValue(RACE_MACHINE)
	c:RegisterEffect(e2)
	--加入手卡 
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,31280141)
	e3:SetCondition(c31280141.condition)
	e3:SetTarget(c31280141.target)
	e3:SetOperation(c31280141.operation)
	c:RegisterEffect(e3)
	--攻守变化       
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SET_BASE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c31280141.value)
	c:RegisterEffect(e4)
    local e5=e4:Clone()
	e5:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e5)
	--墓地特召   
    local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_PHASE+PHASE_END)
    e6:SetRange(LOCATION_GRAVE)
	e6:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e6:SetCountLimit(1,31380141)
    e6:SetCondition(c31280141.condition1)
    e6:SetCost(c31280141.cost)
	e6:SetTarget(c31280141.target1)
	e6:SetOperation(c31280141.operation1)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetCondition(c31280141.condition2)
	c:RegisterEffect(e7)
end
function c31280141.fusfilter1(c)
	return c:IsRace(RACE_ZOMBIE)
end
function c31280141.fusfilter2(c)
	return c:IsRace(RACE_MACHINE)
end
function c31280141.cfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
function c31280141.spcost(e,c,tp,st)
	if st&SUMMON_TYPE_FUSION~=SUMMON_TYPE_FUSION then return true end
	return Duel.IsExistingMatchingCard(c31280141.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
function c31280141.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsPreviousLocation(LOCATION_GRAVE)
end
function c31280141.thfilter(c)
	return c:IsSetCard(0xca2) and c:IsAbleToHand()
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
function c31280141.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280141.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function c31280141.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31280141.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleDeck(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
		if sg:GetCount()>0 then
			Duel.BreakEffect()
			Duel.ShuffleHand(tp)
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
function c31280141.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE)
end
function c31280141.value(e,c)
	return Duel.GetMatchingGroupCount(c31280141.filter,0,LOCATION_GRAVE,0,nil)*400
end
function c31280141.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function c31280141.cfilter1(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsControler(tp) and c:IsRace(RACE_ZOMBIE)
end
function c31280141.condition2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31280141.cfilter1,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
function c31280141.cfilter2(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c31280141.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280141.cfilter2,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c31280141.cfilter2,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c31280141.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c31280141.cfilter3(c)
	return c:IsRace(RACE_MACHINE) and c:IsType(TYPE_MONSTER)
end
function c31280141.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(c31280141.cfilter3,tp,LOCATION_GRAVE,0,nil)
	if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
        and Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):GetCount()>0 
        and g:GetCount()>=7 and Duel.SelectYesNo(tp,aux.Stringid(31280141,0)) then
    	local sg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD):Select(tp,1,1,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.HintSelection(sg)
			Duel.SendtoGrave(sg,REASON_EFFECT)               
		end
	end        
end