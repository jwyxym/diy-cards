--四方主 凌驾
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetRange(LOCATION_EXTRA)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.hspfilter(c,tp,sc)
	return c:IsCode(19420830) and c:IsAbleToRemoveAsCost(POS_FACEDOWN)
		and  Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
end
function s.hspcon(e,c)
	if c==nil then return true end
	return Duel.IsExistingMatchingCard(s.hspfilter,c:GetControler(),LOCATION_HAND,nil,1,nil,e:GetHandlerPlayer(),c)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.hspfilter,tp,LOCATION_HAND,nil,nil,tp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	Duel.Remove(tc,POS_FACEDOWN,REASON_SPSUMMON)
end
function s.thfilter(c)
	return c:IsSetCard(0x597) and c:IsAbleToGrave()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_USE_EXTRA_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(2)
		c:RegisterEffect(e1)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		Duel.BreakEffect()
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_EXTRA,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=g:Select(tp,1,1,nil)
			Duel.SendtoGrave(sg,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
function s.spfilter(c)
	return c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.rmfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		if Duel.SendtoHand(g,tp,REASON_EFFECT)~=0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
			local rc=rg:GetFirst()
			if rc then
			Duel.Remove(rc,POS_FACEDOWN,REASON_EFFECT)
			end
		end
	end
end