--叹息之梦魔镜
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,74665651,1050355)

	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- ① 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.negcon1)
	e1:SetTarget(s.negtg1)   
	e1:SetOperation(s.negop1) 
	c:RegisterEffect(e1)

	-- ② 
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,id+10000)
	e2:SetCondition(s.negcon2)
	e2:SetTarget(s.negtg2)   
	e2:SetOperation(s.negop2) 
	c:RegisterEffect(e2)
end

-- ========== ① ==========
function s.negcon1(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp 
		and re:IsActiveType(TYPE_MONSTER) 
		and Duel.IsChainNegatable(ev) 
		and Duel.IsExistingMatchingCard(s.chk_light,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.chk_light(c)
	return c:IsFaceup() and c:IsCode(74665651)
end

-- ① 
function s.negtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.rm_dark, tp, LOCATION_DECK, 0, 1, nil)  
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

-- ① 
function s.negop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, s.rm_dark, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g>0 then
		Duel.SendtoGrave(g, REASON_EFFECT)
		Duel.NegateActivation(ev)
	end
end
function s.rm_dark(c)
	return c:IsCode(1050355) and c:IsAbleToGrave()
end

-- ========== ② ==========
function s.negcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
		and Duel.IsChainNegatable(ev)
		and Duel.IsExistingMatchingCard(s.chk_dark,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.chk_dark(c)
	return c:IsFaceup() and c:IsCode(1050355)
end

-- ② 
function s.negtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.rm_light, tp, LOCATION_DECK, 0, 1, nil)  
	end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

-- ② 
function s.negop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp, s.rm_light, tp, LOCATION_DECK, 0, 1, 1, nil)  
	if #g>0 then
		Duel.SendtoGrave(g, REASON_EFFECT)
		Duel.NegateActivation(ev)
	end
end
function s.rm_light(c)
	return c:IsCode(74665651) and c:IsAbleToGrave()
end