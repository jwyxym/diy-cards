--杜丝娜瑞尔的圣妖·丝希娜
local m=11110006
local cm=_G["c"..m]
function c11110006.initial_effect(c)
	aux.AddSynchroProcedure(c,nil,cm.filter0,1)
	c:EnableReviveLimit()
local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,m)
	e3:SetCondition(cm.con)
	e3:SetTarget(cm.atktg)
	e3:SetOperation(cm.atkop)
	c:RegisterEffect(e3)
local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,m+100)
	e3:SetCondition(cm.drcon)
	e3:SetTarget(cm.drtg)
	e3:SetOperation(cm.drop)
	c:RegisterEffect(e3)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)

	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cm.fselect(g)
	return g:CheckWithSumEqual(Card.GetLevel,7,1,2)
end
function cm.filter(c,e,tp)
	return c:IsSetCard(0xa61)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function cm.filter1(c,e,tp)
	return c:IsSetCard(0xa61)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsLevelBelow(7) 
end
function cm.drcon(e,tp,eg,ep,ev,re,r,rp)
local rc=e:GetHandler():GetReasonCard()
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO and rc:IsLevelAbove(9) and rc:IsRace(RACE_REPTILE) and e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function cm.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 or not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return false end
if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
local mg=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
		return mg:CheckWithSumEqual(Card.GetLevel,7,1,2)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,nil,tp,LOCATION_GRAVE)
   
end
function cm.drop(e,tp,eg,ep,ev,re,r,rp)
local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
   if ft<=0 or not Duel.IsPlayerCanSpecialSummonCount(tp,2) then return end
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local mg=Duel.GetMatchingGroup(cm.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=mg:SelectSubGroup(tp,cm.fselect,false,1,2)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	
end
function cm.filter0(c) 
	return c:IsRace(RACE_REPTILE) and c:IsAttribute(ATTRIBUTE_DARK)
end 
function cm.filter2(c) 
	return c:IsRace(RACE_REPTILE) and c:IsAbleToGrave()
end
function cm.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa61) and c:IsType(TYPE_MONSTER)
end
function cm.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp)
		and cm.atkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,cm.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function cm.atkop(e,tp,eg,ep,ev,re,r,rp)
	local aa=Duel.SelectMatchingCard(tp,cm.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(aa,REASON_EFFECT)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(aa:GetFirst():GetLevel()*100)
		tc:RegisterEffect(e1)
	   
	end
end