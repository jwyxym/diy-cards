--孵化希望的夏日水镜
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(this.condition)
	e1:SetTarget(this.target)
	e1:SetOperation(this.activate)
	c:RegisterEffect(e1)
end
function this.afilter(c)
    return c:IsFaceup() and c:IsLevel(12) and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_SPELLCASTER)
end
function this.filter(c,tp)
    return not (c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_LIGHT))
end
function this.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(this.afilter,tp,LOCATION_MZONE,0,1,nil)
end
function this.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	local sg=Duel.GetMatchingGroup(this.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
function this.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(this.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	Duel.Destroy(sg,REASON_EFFECT)
end
