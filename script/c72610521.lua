--millsage
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,72610521)
	--ritual summon
	aux.AddRitualProcGreater(c,s.ritualfilter,LOCATION_HAND+LOCATION_GRAVE,s.gravefilter)
	--return to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.gtg)
	e2:SetOperation(s.gop)
	c:RegisterEffect(e2)
end
function s.ritualfilter(c)
	return c:IsType(TYPE_RITUAL) and aux.IsCodeListed(c,id)
end
function s.gravefilter(c)
	return c:IsType(TYPE_SPIRIT)
end
function s.gfilter(c)
	return (c:IsCode(72610500) or c:IsCode(72610515)) and c:IsFaceup() and c:IsAbleToGrave()
end
function s.gtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.gfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.gfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.gfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.gop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
	if tc:IsRelateToEffect(e) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
