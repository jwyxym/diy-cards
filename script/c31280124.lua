--不朽机骸 机甲傀儡
function c31280124.initial_effect(c)
	--种族视为机械族
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_RACE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND)
	e1:SetValue(RACE_MACHINE)
	c:RegisterEffect(e1)
	--战斗送墓    
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
    e2:SetCountLimit(1)
	e2:SetCondition(c31280124.condition)
	e2:SetTarget(c31280124.target)
	e2:SetOperation(c31280124.operation)
	c:RegisterEffect(e2)
	--卡片破坏
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,31280124)
	e3:SetCondition(c31280124.condition1)
	e3:SetTarget(c31280124.target1)
	e3:SetOperation(c31280124.operation1)
	c:RegisterEffect(e3)
end
function c31280124.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0xca2)
end
function c31280124.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and c:IsRelateToBattle() and bc:IsRelateToBattle() and Duel.IsExistingMatchingCard(c31280124.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function c31280124.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler():GetBattleTarget(),1,0,0)
end
function c31280124.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() then
		Duel.SendtoGrave(bc,nil,REASON_EFFECT)
	end
end
function c31280124.ssfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
function c31280124.condition1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_FUSION 
    	and Duel.IsExistingMatchingCard(c31280124.ssfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c31280124.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c31280124.operation1(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
    	Duel.Destroy(tc,REASON_EFFECT)
	end
end