--死灭龙 咒蚀骸龙
local s,id,o=GetID()
function s.initial_effect(c)
	--Xyz Summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),10,3)
	c:EnableReviveLimit()
	--cannot be target/effect indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(s.cost)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--Attach
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(s.mtcon)
	e4:SetTarget(s.mttg)
	e4:SetOperation(s.mtop)
	c:RegisterEffect(e4)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED+LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED+LOCATION_GRAVE,LOCATION_REMOVED+LOCATION_GRAVE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED+LOCATION_GRAVE,LOCATION_REMOVED+LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_ZOMBIE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
function s.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
function s.mtfilter(c,e)
	return c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
function s.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsType(TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,c) end
end
function s.gcheck(g,tp)
	return g:FilterCount(Card.IsControler,nil,tp)<=1
		and g:FilterCount(Card.IsControler,nil,1-tp)<=1
end
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local g=Duel.GetMatchingGroup(s.mtfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local sg=g:SelectSubGroup(tp,s.gcheck,false,1,2,tp)
	if sg:GetCount()>0 then
		Duel.Overlay(c,sg)
	end
end
