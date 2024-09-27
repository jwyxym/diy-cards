--杜丝娜瑞尔·散蛇
local m=11110002
local cm=_G["c"..m]
function c11110002.initial_effect(c)
	local e3=Effect.CreateEffect(c)  
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND) 
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) 
	e3:SetCode(EVENT_TO_GRAVE) 
	e3:SetProperty(EFFECT_FLAG_DELAY)  
	e3:SetCountLimit(1,m)
	e3:SetCondition(function(e) 
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK) and e:GetHandler():IsReason(REASON_EFFECT) end)
	e3:SetTarget(cm.thtg) 
	e3:SetOperation(cm.thop) 
	c:RegisterEffect(e3)
local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(cm.atktg1)
	e2:SetCountLimit(1,m+1000)
	e2:SetOperation(cm.atkop1)
	c:RegisterEffect(e2)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
function cm.atktg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfil1,tp,LOCATION_DECK,0,1,nil) and Duel.IsExistingMatchingCard(cm.thfil2,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function cm.atkop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cm.thfil1,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
	local aa=Duel.SelectMatchingCard(tp,cm.thfil2,tp,LOCATION_HAND,0,1,1,nil)
Duel.SendtoGrave(aa,REASON_EFFECT)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cm.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cm.thfil1(c) 
	return c:IsSetCard(0xa61) and c:IsType(TYPE_MONSTER)
end
function cm.thfil(c) 
	return c:IsRace(RACE_REPTILE) and c:IsType(TYPE_SYNCHRO) 
end 
function cm.thfil2(c) 
	return c:IsRace(RACE_REPTILE) 
end 
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end 
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,LOCATION_GRAVE)
end 
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler() 
if Duel.IsExistingMatchingCard(cm.thfil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
else
Duel.SendtoHand(c,tp,REASON_EFFECT)
end
end
function cm.splimit(e,c)
return not (c:IsRace(RACE_REPTILE))
end
