--
function c20010041.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,20010010,LOCATION_GRAVE+LOCATION_DECK+LOCATION_HAND)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--change race
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb33))
	e1:SetValue(RACE_MACHINE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetTargetRange(LOCATION_GRAVE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb33))
	e2:SetValue(RACE_PSYCHO)
	c:RegisterEffect(e2)
	--maintain
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c20010041.mtcon)
	e3:SetOperation(c20010041.mtop)
	c:RegisterEffect(e3)
	--spsummon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20010041,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,20010041)
	e4:SetCost(c20010041.tkcost)
	e4:SetTarget(c20010041.tktg)
	e4:SetOperation(c20010041.tkop)
	c:RegisterEffect(e4)
end
function c20010041.cfilter(c)
	return c:IsCode(20010010) and not c:IsPublic()
end
function c20010041.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c20010041.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.HintSelection(Group.FromCards(c))
	local g=Duel.GetMatchingGroup(c20010041.cfilter,tp,LOCATION_HAND,0,nil)
	local sel=1
	if g:GetCount()~=0 then
		sel=Duel.SelectOption(tp,aux.Stringid(20010041,0),aux.Stringid(20010041,1))
	else
		sel=Duel.SelectOption(tp,aux.Stringid(20010041,1))+1
	end
	if sel==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local cg=g:Select(tp,1,1,nil)
		Duel.ConfirmCards(1-tp,cg)
		Duel.ShuffleHand(tp)
	else
		Duel.Destroy(c,REASON_COST)
	end
end
function c20010041.costfilter(c)
	return c:IsCode(20010010) and c:IsAbleToRemoveAsCost()
end
function c20010041.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c20010041.costfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c20010041.costfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c20010041.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,20010035,0xb33,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_MACHINE,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function c20010041.tkop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,20010035,0xb33,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_MACHINE,ATTRIBUTE_DARK,POS_FACEUP,tp,0) then
		local token=Duel.CreateToken(tp,20010035)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(c20010041.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		Duel.SpecialSummonComplete()
	end
end
function c20010041.splimit(e,c)
	return not c:IsSetCard(0xb33) and c:IsLocation(LOCATION_EXTRA)
end