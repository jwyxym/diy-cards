--铁机龙战狂·裂核形态
local m=11100013
local cm=_G["c"..m]
function c11100013.initial_effect(c)
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xa60),2)
	c:EnableReviveLimit()
local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m)
	e1:SetCondition(cm.con1)
	e1:SetOperation(cm.spop)
	c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,m)
	e2:SetCondition(cm.con2)
	e2:SetOperation(cm.op2)
	c:RegisterEffect(e2)
end
function cm.op2(e,tp,eg,ep,ev,re,r,rp)
local seq=e:GetHandler():GetSequence()
	local zone=0
	local a
	local b
	 if seq==5 or seq==6 then
	 b=aux.MZoneSequence(seq) end
	if seq>0 and seq<=4 then a=seq-1 
	zone=zone|(1<<(seq-1)) end
	if seq<4 then b=seq+1 
	zone=zone|(1<<(seq+1)) end
local g=Duel.SelectMatchingCard(tp,cm.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
if eg:IsExists(cm.filter4,1,nil,tp,a,b) and Duel.SelectYesNo(tp,aux.Stringid(m,0)) and seq>0 and seq<=4 then
			
Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
else
Duel.SendtoHand(g,tp,REASON_EFFECT)
end
local gl=Duel.GetMatchingGroup(cm.filter5,tp,LOCATION_EXTRA,0,nil)
	if gl:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=gl:Select(tp,1,1,nil)
		Duel.LinkSummon(tp,sg:GetFirst(),nil)
	end
end
function cm.filter5(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa60) and c:IsLinkSummonable(nil)
end
function cm.con2(e,tp,eg,ep,ev,re,r,rp)
	local seq=e:GetHandler():GetSequence()
	local a
	local b
	 if seq==5 or seq==6 then
	 b=aux.MZoneSequence(seq) end
	if seq>0 then a=seq-1 end
	if seq<4 then b=seq+1 end
	return eg:IsExists(cm.filter3,1,nil,tp,a,b) and not eg:IsContains(e:GetHandler())
end
function cm.filter3(c,tp,a,b)
	return c:IsSetCard(0xa60) and c:IsType(TYPE_MONSTER) and c:IsControler(tp) and (c:GetSequence()==a or c:GetSequence()==b)
end
function cm.filter4(c,tp,a,b)
	return c:IsSetCard(0xa60) and c:IsType(TYPE_LINK) and c:IsControler(tp) and (c:GetSequence()==a or c:GetSequence()==b)
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetLinkedGroup()
	local des=Duel.Destroy(mg,REASON_EFFECT)
	if des>0 and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_GRAVE,0,1,nil,des) and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then
	local ml=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_GRAVE,0,1,1,nil,des)
	Duel.SpecialSummon(ml,0,tp,tp,false,false,POS_FACEUP)
   end
end
function cm.filter(c,des)
return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa60) and c:GetLink()==des end

function cm.con1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	return lg:IsExists(cm.filter1,1,nil)
end
function cm.filter1(c)
return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xa60) end




