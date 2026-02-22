--救世游戏-暗影领域
local s,id,o=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--不会成为效果对象    
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tgtg)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--无效
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
    e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)    
end
function s.tgtg(e,c)
	local seq=c:GetSequence()
	return c:IsSetCard(0xdf99) and seq<5 and math.abs(e:GetHandler():GetSequence()-seq)<=1 
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ev)
end
function s.costfilter(c,lg)
	return c:IsSetCard(0xdf99) and c:GetSequence()<5 and lg:IsContains(c)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetColumnGroup()
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,lg) end
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,lg)
	Duel.Release(g,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end