-- 烬雪的长旅·齐格
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,nil,3,99,s.lcheck)
	--cannot be link material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
function s.lfilter(c)
	return c:IsLinkType(TYPE_NORMAL) or c:IsLinkSetCard(0xe93)
end
function s.lcheck(g)
	return g:IsExists(s.lfilter,1,nil)
end
function s.tdfilter(c)
	return c:GetOriginalType()&TYPE_MONSTER>0 and c:IsAbleToDeck()
end
function s.tdfilter2(c)
	return c:IsSetCard(0xe93) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_ONFIELD) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_GRAVE+LOCATION_ONFIELD,1,nil) and Duel.IsExistingMatchingCard(s.tdfilter2,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,LOCATION_GRAVE+LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.tdfilter2,tp,LOCATION_HAND,0,1,1,nil)
		g:AddCard(tc)
		Duel.ConfirmCards(1-tp,g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
