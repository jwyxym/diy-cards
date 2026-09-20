--逃离疯狂梦境的爱丽丝
function c19991021.initial_effect(c)
	--change code
	aux.EnableChangeCode(c,19991003,LOCATION_SZONE+LOCATION_GRAVE)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19991018,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE+LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19991021)
	e1:SetTarget(c19991021.rmtg)
	e1:SetOperation(c19991021.rmop)
	c:RegisterEffect(e1)
	--can not chain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE+LOCATION_MZONE)
	e2:SetOperation(c19991021.ccop)
	c:RegisterEffect(e2)
end
function c19991021.rmfilter(c)
	return c:IsSetCard(0xb31) and c:IsAbleToRemove()
end
function c19991021.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19991021.rmfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	local g=Duel.GetMatchingGroup(c19991021.rmfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c19991021.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c19991021.rmfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function c19991021.ccop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if ep==tp and re:IsActiveType(TYPE_MONSTER) and tc:IsSetCard(0xb31) then
		Duel.SetChainLimit(c19991021.chainlm)
	end
end
function c19991021.chainlm(e,rp,tp)
	return tp==rp
end