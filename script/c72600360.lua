--来自深海的人鱼
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,72600351)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),6,2)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--cannot be target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.immtg)
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	--to hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1,id)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.cost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e5:SetCondition(s.thcon)
	c:RegisterEffect(e5)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsRace,1,nil,RACE_AQUA) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_HAND)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local hg=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local fg=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	local g
	if #hg>0 and (#fg==0 or Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0) then
		g=hg:RandomSelect(tp,1)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	end
	if g:GetCount()~=0 then
		Duel.HintSelection(g)
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.immtg(e,c)
	return (c:IsCode(72600351) or aux.IsCodeListed(c,72600351)) and c:IsFaceup()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.rccfilter(c)
	return c:IsFaceupEx() and c:IsCode(72600351)
end
function s.thcon(e,tp)
	return Duel.IsExistingMatchingCard(s.rccfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local g1=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local g2=aux.SelectTargetFromFieldFirst(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,g1:GetCount(),0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	tg=tg:Filter(aux.NecroValleyFilter(),nil)
	if #tg>0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
