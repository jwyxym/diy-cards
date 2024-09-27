--祭法魔女法坛
local m=21300121
local cm=_G["c"..m]
function c21300121.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,m+100)
	e2:SetCondition(cm.thcon)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,m)
	e3:SetTarget(cm.tg)
	e3:SetOperation(cm.thop2)
	c:RegisterEffect(e3)
end
function cm.spnfilter(c,e,tp)
	return c:IsSetCard(0x676) and c:IsType(TYPE_MONSTER) and (c:IsPreviousLocation(LOCATION_HAND) or c:IsPreviousLocation(LOCATION_ONFIELD))
end
function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(cm.spnfilter,1,nil,e,tp) and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_DECK,0,1,nil)
end
function cm.filter(c)
	return c:IsSetCard(0x676) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsType(TYPE_MONSTER) and chkc:IsSetCard(0x676) end
	if chk==0 then return Duel.IsExistingMatchingCard(function(c) return c:IsSetCard(0x676) and c:IsType(TYPE_MONSTER) end,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local g=Duel.SelectTarget(tp,function(c) return c:IsSetCard(0x676) and c:IsType(TYPE_MONSTER) end,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function cm.thop2(e,tp,eg,ep,ev,re,r,rp)
   local tc=Duel.GetFirstTarget()
if tc and tc:IsRelateToEffect(e) then -- fixed by k3
Duel.SendtoHand(tc,tp,REASON_EFFECT)
end
end

