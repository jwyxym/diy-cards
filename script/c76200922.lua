--冰华的霜姬 艾瑞丝
local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x762),4,2)
	c:EnableReviveLimit()
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--act qp/trap in hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetTarget(s.handtg)
	e2:SetCondition(s.handcon)
	e2:SetCost(s.handcost)
	e2:SetValue(id)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(id)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetRange(LOCATION_MZONE)
	c:RegisterEffect(e4)
	--material
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+o)
	e5:SetTarget(s.mvtg)
	e5:SetOperation(s.mvop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetLabelObject(e5)
	e6:SetOperation(s.regop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_CHAIN_NEGATED)
	e7:SetOperation(s.regop2)
	c:RegisterEffect(e7)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.thfilter(c)
	return c:IsSetCard(0x762) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.handcon(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
function s.similarfilter(c,tp)
	return c:IsHasEffect(id) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
end
function s.handcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	local g=Duel.GetMatchingGroup(s.similarfilter,tp,LOCATION_MZONE,0,c,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
		local tc=(g+c):Select(tp,1,1,nil):GetFirst()
		tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	else
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end
function s.handtg(e,c)
	return c:IsSetCard(0x762)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:GetHandler():IsSetCard(0x762) and re:IsActiveType(TYPE_SPELL) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local flag=c:GetFlagEffectLabel(id)
		if flag then
			c:SetFlagEffectLabel(id,flag+1)
		else
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,1)
		end
	end
end
function s.regop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:GetHandler():IsSetCard(0x762) and re:IsActiveType(TYPE_SPELL) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local flag=c:GetFlagEffectLabel(id)
		if flag and flag>0 then
			c:SetFlagEffectLabel(id,flag-1)
		end
	end
end
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetFlagEffectLabel(id)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and ct and ct>0
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.mtfilter(c)
	return c:IsSetCard(0x762) and c:IsType(TYPE_SPELL) and c:IsCanOverlay()
end
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ct=e:GetHandler():GetFlagEffectLabel(id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_GRAVE,0,1,ct,nil)
	if g:GetCount()>0 then
		Duel.Overlay(c,g)
	end
end