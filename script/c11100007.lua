--铁机龙战·协同补给手
local m=11100007
local cm=_G["c"..m]
function c11100007.initial_effect(c)
	 local e2=Effect.CreateEffect(c)
	 e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(cm.con2)
	e2:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,m+1000)
	e3:SetCondition(cm.con)
	e3:SetTarget(cm.thtg)
	e3:SetOperation(cm.thop)
	c:RegisterEffect(e3)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(cm.filter3,tp,LOCATION_MZONE,0,1,nil,tp,c)
end
function cm.filter3(c,tp,tc)
local seq=tc:GetSequence()
	local a
	local b
	if seq>0 then a=seq-1 end
	if seq<4 then b=seq+1 end
	return c:IsSetCard(0xa60) and c:IsControler(tp) and (c:GetSequence()==a or c:GetSequence()==b)
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.filter1,tp,LOCATION_GRAVE,0,1,nil) end
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
local g=Duel.GetMatchingGroup(cm.filter1,tp,LOCATION_GRAVE,0,nil)
local ta=Duel.GetMatchingGroup(cm.filter4,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
if g:GetCount()>0 then 
			Duel.BreakEffect() 
   local tc=g:Select(tp,1,1,nil):GetFirst() 
if ta:GetClassCount(Card.GetCode)>=3 and Duel.SelectYesNo(tp,aux.Stringid(m,0)) then
Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
else
			
			Duel.SendtoHand(tc,tp,REASON_EFFECT)
end
end
end
function cm.filter4(c,tp,tc)
return c:IsSetCard(0xa60)
end
function cm.filter1(c,tp)
return c:IsSetCard(0xa60) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_LINK)
end
function cm.con2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.filter2,1,nil,tp)
end
function cm.filter2(c,tp)
return Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_ONFIELD,0,1,nil,c)
end
function cm.filter(c,mc)
	local seq=mc:GetSequence()
	local a
	local b
	if seq>0 then a=seq-1 end
	if seq<4 then b=seq+1 end
	return (c:GetSequence()==a or c:GetSequence()==b) and c:IsSetCard(0xa60)
end
function cm.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
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
