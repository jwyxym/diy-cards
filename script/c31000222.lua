--捕食日轮之角 
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.AddCodeList(c,31000201)
	--negateeffect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(this.condition)
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(this.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(this.setcon)
	e2:SetTarget(this.settg)
	e2:SetOperation(this.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCondition(this.setcon2)
	c:RegisterEffect(e3)
end
function this.cfilter(c)
	return c:IsFaceup() and (c:IsCode(31000201) or aux.IsCodeListed(c,31000201) and c:IsType(TYPE_RITUAL))
end
function this.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(this.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function this.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
function this.setfilter(c,tp)
	return c:IsFaceup() and aux.IsCodeListed(c,31000201) and c:IsType(TYPE_RITUAL) and c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsControler(tp)
end
function this.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(this.setfilter,1,nil,tp)
end
function this.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function this.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
function this.setfilter2(c,tp)
	return c:IsFaceup() and aux.IsCodeListed(c,31000201) and c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsControler(tp)
end
function this.setcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(this.setfilter2,1,nil,tp)
end
