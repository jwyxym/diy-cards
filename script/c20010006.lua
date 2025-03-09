--
function c20010006.initial_effect(c)
	c:SetSPSummonOnce(20010006)
	--cannot special summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(c20010006.splimit)
	c:RegisterEffect(e0)
	--cost
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e1:SetCountLimit(1)
	e1:SetDescription(aux.Stringid(20010006,5))
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c20010006.mtcon)
	e1:SetOperation(c20010006.mtop)
	c:RegisterEffect(e1)
	--Special Summon1
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20010006,3))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCost(c20010006.spcost1)
	e2:SetTarget(c20010006.sptg1)
	e2:SetOperation(c20010006.spop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(20010006,2))
	e3:SetCost(c20010006.spcost2)
	c:RegisterEffect(e3)
	--
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20010006,4))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetCountLimit(1,20010006)
	e4:SetCost(c20010006.cost)
	e4:SetCondition(c20010006.condition)
	e4:SetTarget(c20010006.target)
	e4:SetOperation(c20010006.operation)
	c:RegisterEffect(e4)
	--disable summon
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(1,0)
	e5:SetTarget(c20010006.sumlimit)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e7)
end
function c20010006.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xb33)
end
function c20010006.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
function c20010006.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c20010006.cfilter(c)
	return c:IsCode(20010010) and not c:IsPublic()
end
function c20010006.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.HintSelection(Group.FromCards(c))
	local g=Duel.GetMatchingGroup(c20010006.cfilter,tp,LOCATION_HAND,0,nil)
	local sel=1
	if g:GetCount()~=0 then
		sel=Duel.SelectOption(tp,aux.Stringid(20010006,0),aux.Stringid(20010006,1))
	else
		sel=Duel.SelectOption(tp,aux.Stringid(20010006,1))+1
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
function c20010006.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c20010006.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c20010006.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function c20010006.costfilter(c)
	return c:IsSetCard(0xb33) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c20010006.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(c20010006.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c20010006.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c20010006.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c20010006.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
function c20010006.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function c20010006.confilter(c)
	return c:IsSetCard(0xb33) and c:IsFaceup()
end
function c20010006.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c20010006.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function c20010006.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c20010006.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end