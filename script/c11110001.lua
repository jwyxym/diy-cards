--杜丝娜瑞尔·魔斩
local m=11110001
local cm=_G["c"..m]
function c11110001.initial_effect(c)
local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,m)
	e1:SetCondition(cm.condition)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetLabelObject(e0)
	e2:SetCountLimit(1,m+1000)
	e2:SetCondition(cm.condition2)
	e2:SetTarget(cm.target2)
	e2:SetOperation(cm.activate2)
	c:RegisterEffect(e2)
end
function cm.condition2(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(cm.spnfilter,1,e:GetHandler(),se)
end
function cm.spnfilter(c,se)
return c:IsRace(RACE_REPTILE) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_DECK) and (se==nil or c:GetReasonEffect()~=se) end

function cm.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
function cm.activate2(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler() 
Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e3:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e3,true)
if eg:IsExists(Card.IsSetCard,1,e:GetHandler(),0xa61) and Duel.IsPlayerCanDraw(tp,1) then
Duel.Draw(tp,1,REASON_EFFECT)
end
local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cm.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cm.splimit(e,c)
return not (c:IsRace(RACE_REPTILE))
end
function cm.thfil1(c) 
	return c:IsSetCard(0xa61) and c:IsType(TYPE_MONSTER)  
end
function cm.thfil(c) 
	return c:IsRace(RACE_REPTILE)
end
function cm.condition(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.thfil1,tp,LOCATION_HAND,0,1,nil) and not e:GetHandler():IsPublic() end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
Duel.ConfirmCards(1-tp,e:GetHandler()) 
	Duel.ShuffleHand(tp) 
local aa=Duel.SelectMatchingCard(tp,cm.thfil1,tp,LOCATION_HAND,0,1,1,nil)
Duel.SendtoGrave(aa,REASON_EFFECT)
local g=Duel.GetMatchingGroup(cm.thfil,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local tc=g:GetFirst()
	while tc do
 local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end








