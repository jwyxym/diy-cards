--DS 海后安菲兽
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),6,3,s.ovfilter,aux.Stringid(id,0),nil,s.xyzop)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.negcost)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	c:RegisterEffect(e2)
end
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb74) and c:IsType(TYPE_XYZ) and c:IsRank(5)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 and Duel.GetFlagEffect(tp,id+o)==0 end
	Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.disfilter(c)
	return c:IsDiscardable()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local max=Duel.GetMatchingGroup(s.negfilter,tp,0,LOCATION_ONFIELD,nil,e,tp)
    local m=#max
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_HAND,0,1,m,nil)
	e:SetLabel(g:GetCount())
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
function s.negfilter(c)
	return c:IsFaceup() and aux.NegateAnyFilter(c)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and s.negfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.negfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.negfilter,tp,0,LOCATION_ONFIELD,1,e:GetLabel(),nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	for tc in aux.Next(g) do
		if tc:IsFaceup() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_MONSTER) then
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_SET_ATTACK_FINAL)
				e3:SetValue(0)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e3)
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(EFFECT_SET_DEFENSE_FINAL)
				e4:SetValue(0)
				e4:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e4)
			end
		end
	end
end
function s.dsfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0xb74) and c:GetReasonPlayer()==1-tp
end
function s.repfilter(c)
	return c:IsAbleToDeck() 
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.dsfilter,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.repfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),aux.Stringid(id,2)) then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,s.repfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		return true
	else return false end
end
function s.repval(e,c)
	return s.dsfilter(c,e:GetHandlerPlayer())
end
