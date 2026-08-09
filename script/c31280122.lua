--圆滚滚2号
function c31280122.initial_effect(c)
	aux.AddCodeList(c,31280120)
	--融合召唤
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),c31280122.matfilter,true)
	c:EnableReviveLimit()
	--加入手卡    
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(31280122,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,31280122)
	e1:SetCondition(c31280122.condition)
	e1:SetTarget(c31280122.target)
	e1:SetOperation(c31280122.operation)
	c:RegisterEffect(e1)
	--效破抗性    
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--攻击限制    
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetValue(c31280122.atlimit)
	c:RegisterEffect(e3)
	--伤害并回复
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31280122,1))
	e4:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
    e4:SetCondition(c31280122.condition1)
	e4:SetTarget(c31280122.target1)
	e4:SetOperation(c31280122.operation1)
	c:RegisterEffect(e4)
end
function c31280122.matfilter(c)
	return c:IsRace(RACE_MACHINE)
end
function c31280122.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
function c31280122.thfilter(c)
	return (c:IsCode(31280120) or aux.IsCodeListed(c,31280120)) and c:IsAbleToHand() and not c:IsType(TYPE_FUSION)
end
function c31280122.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c31280122.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c31280122.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c31280122.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c31280122.atlimit(e,c)
	return c~=e:GetHandler()
end
function c31280122.confilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE+RACE_MACHINE)
end
function c31280122.condition1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c31280122.confilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function c31280122.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,800)
end
function c31280122.operation1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(1-tp,800,REASON_EFFECT)
    Duel.Recover(tp,800,REASON_EFFECT)
end