--铁机龙战·中央智脑
local m=11100010
local cm=_G["c"..m]
function c11100010.initial_effect(c)
	c:SetSPSummonOnce(11100010)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,cm.matfilter,1,1) 
local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,m)
	e1:SetCondition(cm.thcon)
	e1:SetTarget(cm.thtg)
	e1:SetOperation(cm.thop)
	c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(cm.con2)
	e2:SetCost(cm.cost)
	e2:SetCountLimit(1,m+1000+EFFECT_COUNT_CODE_DUEL)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)

end
function cm.op2(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(eg:GetFirst():GetCode())
	c:RegisterEffect(e1)
local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetTargetRange(1,0)
	e2:SetTarget(cm.splimit2)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function cm.splimit2(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0xa60)
end
function cm.cost(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.CheckLPCost(tp,eg:GetFirst():GetAttack()) end
Duel.PayLPCost(tp,eg:GetFirst():GetAttack())
end
function cm.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.filter2,1,nil,tp)
end
function cm.filter2(c,tp)
return c:IsRace(RACE_PSYCHO) and c:IsAttribute(ATTRIBUTE_DARK) and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_ONFIELD,0,1,nil,c)
end
function cm.filter(c,tc)
	local seq=tc:GetSequence()
	local a
	local b
	if seq==5 or seq==6 then
	 b=aux.MZoneSequence(seq) end
	if seq>0 then a=seq-1 end
	if seq<4 then b=seq+1 end
	return (c:GetSequence()==a or c:GetSequence()==b) and c:IsSetCard(0xa60) and c:IsType(TYPE_MONSTER)
end
function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function cm.thfilter(c)
	return c:IsCode(11100001) and c:IsAbleToHand()
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function cm.matfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAttribute(ATTRIBUTE_DARK)
end
