--杜丝娜瑞尔之还魂
local m=11110011
local cm=_G["c"..m]
function c11110011.initial_effect(c)
	local e3=Effect.CreateEffect(c) 
	e3:SetType(EFFECT_TYPE_ACTIVATE) 
	e3:SetCode(EVENT_FREE_CHAIN) 
	c:RegisterEffect(e3)
local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1,m)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop1)
	c:RegisterEffect(e2)
 local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,m)
	e1:SetCondition(cm.thcon)
	e1:SetOperation(cm.thop)
	c:RegisterEffect(e1)
end
function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsExists(cm.sfilter,1,nil)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=eg:Filter(cm.sfilter,nil,tp)
	local aa=g:Select(tp,1,1,nil)
	if #aa>0 then
		Duel.SpecialSummon(aa,0,tp,tp,false,false,POS_FACEUP)
	end
local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
	e3:SetValue(LOCATION_DECK)
	aa:GetFirst():RegisterEffect(e3,true)
end
function cm.sfilter(c)
	return c:IsSetCard(0xa61) and c:IsType(TYPE_MONSTER)
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.sfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function cm.thop1(e,tp,eg,ep,ev,re,r,rp)
local aa=Duel.SelectMatchingCard(tp,cm.sfilter,tp,LOCATION_GRAVE,0,1,1,nil)
Duel.SendtoDeck(aa,tp,2,REASON_EFFECT)
end













