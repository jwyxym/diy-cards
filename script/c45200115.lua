--帝王压杀
local s,id=GetID()

local seq = {LINK_MARKER_BOTTOM, LINK_MARKER_BOTTOM_RIGHT, LINK_MARKER_RIGHT, LINK_MARKER_BOTTOM_RIGHT, LINK_MARKER_BOTTOM, LINK_MARKER_BOTTOM_LEFT, LINK_MARKER_LEFT}

function s.initial_effect(c)
	--①效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.linkfilter(c)
	return c:IsType(TYPE_LINK) and c:GetLink()==1
end

function s.attfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_FIRE+ATTRIBUTE_EARTH)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.linkfilter,tp,LOCATION_EXTRA,0,1,nil)
			and Duel.IsExistingMatchingCard(s.attfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local match=true
	for i=1,#seq do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg=Duel.SelectMatchingCard(tp,s.linkfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if #sg==0 then match=false; break end
		local tc=sg:GetFirst()
		Duel.ConfirmCards(1-tp,tc)
		if tc:GetLinkMarker()~=seq[i] then match=false; break end
	end
	
	if not match then
		Duel.Damage(tp,100,REASON_EFFECT)
		return
	end
	
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local ag=Duel.SelectMatchingCard(tp,s.attfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if #ag==0 then
		Duel.Damage(tp,100,REASON_EFFECT)
		return
	end
	local ac=ag:GetFirst()
	if ac:IsLocation(LOCATION_DECK) then
		Duel.ConfirmCards(tp,ac)
		Duel.ShuffleDeck(tp)
	else
		Duel.ConfirmCards(1-tp,ac)
	end
	
	local dg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

return s