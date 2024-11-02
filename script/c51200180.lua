--一闪
function c51200180.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCondition(c51200180.condition)
	e1:SetCountLimit(1,51200180)
	e1:SetTarget(c51200180.target)
	e1:SetOperation(c51200180.activate)
	c:RegisterEffect(e1)
end
	function c51200180.actcfilter(c)
	return c:IsSetCard(0x65d) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
end
	function c51200180.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.GetCurrentChain()==0
		and Duel.IsExistingMatchingCard(c51200180.actcfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
	function c51200180.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
	function c51200180.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
end