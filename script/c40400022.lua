--算子械方程式-β
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.lvfilter(c)
	return c:IsFaceup()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	e:SetLabel(Duel.AnnounceLevel(tp,1,4))
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if tc:IsLevelAbove(1) then
			local lv=e:GetLabel()
			if not tc:IsLevelAbove(lv+1) then
				sel=Duel.SelectOption(tp,aux.Stringid(id,3))
			else
				sel=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
			end
			if sel==1 then
				lv=-lv
			end
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_ADD_TYPE)
			e3:SetValue(TYPE_NORMAL)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			local e5=e3:Clone()
			e5:SetCode(EFFECT_REMOVE_TYPE)
			e5:SetValue(TYPE_EFFECT)
			tc:RegisterEffect(e5)
		else
			Duel.SendtoGrave(tc,REASON_RULE)
		end
	end
end
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_NORMAL) and c:IsLevelAbove(1) and c:IsAbleToDeck()
end
function s.thfilter(c,g)
	return c:IsFaceupEx() and c:IsSetCard(0x404) and c:IsLevelAbove(1) and not g:IsExists(Card.IsLevel,1,nil,c:GetLevel()) and c:IsAbleToHand()
end
function s.thgcheck(g,tp)
	return aux.dlvcheck(g)
end
function s.gcheck(g,tp)
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil,g)
	return sg:CheckSubGroup(s.thgcheck,2,2,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		return g:CheckSubGroup(s.gcheck,1,3,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,1,3,tp)
	if sg:GetCount()>0 then
		if Duel.SendtoDeck(sg,nil,2,REASON_EFFECT) and sg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
			local ssg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil,sg)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local tsg=ssg:SelectSubGroup(tp,s.thgcheck,false,2,2,tp)
			if tsg:GetCount()>0 then
				Duel.BreakEffect()
				Duel.SendtoHand(tsg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,tsg)
			end
		end
	end
end