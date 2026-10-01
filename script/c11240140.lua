-- 七代码 PAD
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2:SetCost(s.matcost)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
function s.rlfilter(c,tp)
  local re=Duel.IsPlayerAffectedByEffect(tp,EFFECT_CANNOT_RELEASE)
  local val=nil
  if re then val=re:GetValue() end
  return (c:IsReleasable(REASON_EFFECT) or (c:IsType(TYPE_SPELL+TYPE_TRAP) and (val==nil or val(re,c)~=true))) and c:IsSetCard(0xb94) 
end
function s.filter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0xb94) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
end
function s.spfilter(c,e,tp)
	return c:IsCode(11240130) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
  if chk==0 then return Duel.IsExistingMatchingCard(s.rlfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,0,tp,LOCATION_HAND+LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
  local g=Duel.SelectMatchingCard(tp,s.rlfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,99,e:GetHandler())
	if Duel.SendtoGrave(g,REASON_EFFECT+REASON_RELEASE)~=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,7,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
		  Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(11240130) and c:IsType(TYPE_XYZ)
end
function s.matcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() and aux.NecroValleyFilter()(c) end
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.HintSelection(g)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local mg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCanOverlay),tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,7,nil)
	if mg:GetCount()>0 then
		Duel.HintSelection(mg)
		Duel.Overlay(g:GetFirst(),mg)	
	end
end