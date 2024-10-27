--祭法魔女 珀
local m=21300123
local cm=_G["c"..m]
function c21300123.initial_effect(c)
	 local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,m)
	e2:SetCondition(cm.con0)
	e2:SetOperation(cm.ssop)
	c:RegisterEffect(e2)
	 local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,m+10000)
	e1:SetTarget(cm.tg)
	e1:SetCondition(cm.thcon)
	e1:SetOperation(cm.thop)
	c:RegisterEffect(e1)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,m+10000)
	e3:SetTarget(cm.tg)
	e3:SetOperation(cm.thop)
	e3:SetCode(EVENT_RELEASE)
	c:RegisterEffect(e3)
end
function cm.con0(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsExistingMatchingCard(function(c) return c:IsType(TYPE_MONSTER) and c:IsReleasable() and c:IsRace(RACE_SPELLCASTER) end,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) or Duel.IsExistingMatchingCard(function(c) return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost() end,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	
function cm.ssop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,function(c) return (c:IsType(TYPE_MONSTER) and c:IsReleasable() and c:IsRace(RACE_SPELLCASTER)) or (c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()) end,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	if g:GetFirst():IsType(TYPE_MONSTER) then
	Duel.Release(g,REASON_COST)
	else 
	Duel.SendtoGrave(g,REASON_COST)
   end
end
function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsRace(RACE_SPELLCASTER)
end
function cm.filter2(c)
return (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsSetCard(0x676) and c:IsAbleToHand() end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter2,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.filter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end













