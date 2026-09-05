--斩雪剑
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,45205409)
	
	--①效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:GetEquipGroup():GetCount()>0
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and (re:IsActiveType(TYPE_SPELL) or re:IsActiveType(TYPE_TRAP))
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
	if Duel.IsExistingMatchingCard(s.shujofilter,tp,LOCATION_MZONE,0,1,nil) then
		local c=e:GetHandler()
		--自己场上「皇帝龙淑女」和有这个卡名记述的卡不受对方的卡的效果影响
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetTargetRange(LOCATION_ONFIELD,0)
		e1:SetTarget(s.imetg)
		e1:SetValue(s.efilter)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.shujofilter(c)
	return c:IsFaceup() and c:IsCode(45205409)
end

function s.imetg(e,c)
	return c:IsCode(45205409) or aux.IsCodeListed(c,45205409)
end

function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

return s
