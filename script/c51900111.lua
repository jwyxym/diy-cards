--《戒律·骑士》白之王女
local s,id,o=GetID()
function s.initial_effect(c)
	aux.EnableChangeCode(c,51900003,LOCATION_MZONE+LOCATION_GRAVE)
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT+ATTRIBUTE_DARK+ATTRIBUTE_FIRE),aux.NonTuner(Card.IsRace,RACE_FAIRY+RACE_WARRIOR+RACE_DRAGON),1)
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.lvcon)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	e0:SetLabelObject(e1)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if not g:IsExists(Card.IsNotTuner,1,nil,e:GetHandler()) then 
		e:GetLabelObject():SetLabelObject(nil)
		return
	end
	e:GetLabelObject():SetLabelObject(g)
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject() and e:GetLabelObject():IsExists(Card.IsNotTuner,1,nil,e:GetHandler()) end
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local sel=nil
	if c:IsLevel(1) then
		sel=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		sel=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	end
	local lvt={}
	local g=c:GetMaterial()
	local sg=g:Filter(Card.IsNotTuner,nil,e:GetHandler())
	Debug.Message(sg:GetCount())
	Duel.ConfirmCards(tp,g)
	Duel.ConfirmCards(tp,sg)
	g:DeleteGroup()
	for tc in aux.Next(sg) do
		local tlv=tc:GetLevel()
		if not (sel==1 and c:GetLevel()<tlv) then
			lvt[tlv]=tlv
		end
	end
	if lvt[5] then
		Debug.Message(lvt[5])
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	if sel==1 then
		lv=lv*-1
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(lv)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x512) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end