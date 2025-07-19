--邪魔的先导
function c19000090.initial_effect(c)
	c:SetUniqueOnField(1,0,19000090)
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,c19000090.mfilter,nil,2,99)
	--attach
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19000090,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,19000090)
	e1:SetTarget(c19000090.mattg)
	e1:SetOperation(c19000090.mattop)
	c:RegisterEffect(e1)
	--as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19000090,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DETACH_MATERIAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,19000090+100)
	e2:SetTarget(c19000090.xmtg)
	e2:SetOperation(c19000090.xmop)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19000090,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,19000090+200)
	e3:SetCondition(c19000090.condition1)
	e3:SetTarget(c19000090.target)
	e3:SetOperation(c19000090.activate)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(19000090,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,19000090+200)
	e4:SetCondition(c19000090.condition2)
	e4:SetTarget(c19000090.target)
	e4:SetOperation(c19000090.activate)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(19000090,2))
	e7:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EVENT_TO_HAND)
	e7:SetCountLimit(1,19000090+200)
	e7:SetCondition(c19000090.condition3)
	e7:SetTarget(c19000090.target)
	e7:SetOperation(c19000090.activate)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(19000090,2))
	e8:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_REMOVE)
	e8:SetProperty(EFFECT_FLAG_DELAY)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCountLimit(1,19000090+200)
	e8:SetCondition(c19000090.condition4)
	e8:SetTarget(c19000090.target)
	e8:SetOperation(c19000090.activate)
	c:RegisterEffect(e8)
end
function c19000090.mafilter(c,xyzc)
	return c:IsXyzLevel(xyzc,9) or (c:IsType(TYPE_XYZ) and c:IsRank(9))
end
function c19000090.matfilter(c)
	return (c:IsRank(9) or c:IsLevel(9)) and c:IsCanOverlay()
end
function c19000090.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(c19000090.matfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
end
function c19000090.mattop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectMatchingCard(tp,c19000090.matfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Overlay(c,g)
	end
end
function c19000090.xmfilter(c)
	return c:IsCanOverlay()
end
function c19000090.xmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(c19000090.xmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,LOCATION_HAND+LOCATION_ONFIELD,1,nil) end
end
function c19000090.xmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local sg=Group.CreateGroup()
		local tg1=Duel.GetMatchingGroup(c19000090.xmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,aux.ExceptThisCard(e),e)
		if tg1:GetCount()>0 then
			Duel.ShuffleHand(tp)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local tc1=tg1:Select(tp,1,1,nil):GetFirst()
			if tc1 then
				tc1:CancelToGrave()
				sg:AddCard(tc1)
			end
		end
		local tg2=Duel.GetMatchingGroup(c19000090.xmfilter,1-tp,LOCATION_HAND+LOCATION_ONFIELD,0,aux.ExceptThisCard(e),e)
		if tg2:GetCount()>0 then
			Duel.ShuffleHand(1-tp)
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_XMATERIAL)
			local tc2=tg2:Select(1-tp,1,1,nil):GetFirst()
			if tc2 then
				tc2:CancelToGrave()
				sg:AddCard(tc2)
			end
		end
		if sg:GetCount()>0 then
			Duel.BreakEffect()
			for tc in aux.Next(sg) do
				local og=tc:GetOverlayGroup()
				if og:GetCount()>0 then
					Duel.SendtoGrave(og,REASON_RULE)
				end
			end
			Duel.Overlay(c,sg)
		end
	end
end
function c19000090.condition1(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function c19000090.condition2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,e:GetHandler(),1-tp)
end
function c19000090.ccfilter3(c,tp)
	return c:IsControler(tp) and not c:IsReason(REASON_DRAW)
end
function c19000090.condition3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19000090.ccfilter3,1,nil,1-tp)
end
function c19000090.ccfilter4(c,tp)
	return c:IsPreviousControler(1-tp)
end
function c19000090.condition4(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19000090.ccfilter4,1,nil,tp)
end
function c19000090.filter(c,e,tp)
	return c:IsLevel(9) and aux.AtkEqualsDef(c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c19000090.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19000090.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c19000090.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c19000090.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end