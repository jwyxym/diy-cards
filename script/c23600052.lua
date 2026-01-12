--苍忘胧灵·柳离
local s,id,o=GetID()
function s.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,s.matfilter,5,2,s.ovfilter,aux.Stringid(id,0),99,s.xyzop1)
	c:EnableReviveLimit()
	--destroy replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.desreptg)
	e1:SetValue(s.desrepval)
	e1:SetOperation(s.desrepop)
	c:RegisterEffect(e1)
	--to deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	--material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
function s.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
function s.ovfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ) and c:IsRank(5)
end
function s.xfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
function s.xyzop1(e,tp,chk) 
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(s.xfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	local sg=Duel.GetMatchingGroup(s.xfilter,tp,LOCATION_MZONE,0,nil,tp)
	if sg:GetCount()==0 then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)
	local tc=sg:Select(tp,1,1,nil):GetFirst()
	if tc then
		tc:RemoveOverlayCard(tp,1,1,REASON_COST)
	end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
	return true
end
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	Duel.Hint(HINT_CARD,0,id)
end
function s.xyzfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.xyzfilter(chkc) end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(s.xyzfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectTarget(tp,s.xyzfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetPreviousOverlayCountOnField()>0 and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
function s.tdfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and ((c:IsLevel(5) and c:IsAbleToDeck()) or (c:IsRank(5) and c:IsAbleToExtra()))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) and c:IsAbleToDeck() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
