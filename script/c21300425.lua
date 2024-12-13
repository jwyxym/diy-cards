--炎夜时的庇护
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(this.condition)
	e1:SetTarget(this.target)
	e1:SetOperation(this.activate)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(this.con)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(this.tg)
    e2:SetOperation(this.op)
    c:RegisterEffect(e2)
end
function this.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x678)
end
function this.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(this.confilter,tp,LOCATION_MZONE,0,1,nil) then return end
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function this.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function this.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
function this.filter(c,tp)
    return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
function this.tgfilter(c)
    return c:IsSetCard(0x678) and c:IsAbleToGrave()
end
function this.con(e,tp,eg,ep,ev,re,r,rp)
    return aux.exccon(e) and eg:IsExists(this.filter,1,nil,tp)
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.tgfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=Duel.SelectMatchingCard(tp,this.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
    Duel.SendtoGrave(tc,REASON_EFFECT)
end
