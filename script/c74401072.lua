local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,74401085)

	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),6,2)
	c:EnableReviveLimit()

	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.xyzcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY+CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.matcost)
	e2:SetTarget(s.seltg)
	e2:SetOperation(s.selop)
	c:RegisterEffect(e2)
end

function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsLevel(6) and aux.IsCodeListed(c,74401085)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.matcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(2500)
end
function s.stfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function s.gyfilter(c)
	return c:IsAbleToRemove()
end
function s.seltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local sel=e:GetLabel()
		if sel==2 then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
		if sel==3 then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and s.stfilter(chkc) end
		if sel==4 then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and s.gyfilter(chkc) end
		return false
	end
	if chk==0 then return true end
	local codes={1}
	if Duel.IsExistingTarget(s.atkfilter,tp,0,LOCATION_MZONE,1,nil) then codes[#codes+1]=2 end
	if Duel.IsExistingTarget(s.stfilter,tp,0,LOCATION_SZONE,1,nil) then codes[#codes+1]=3 end
	if Duel.IsExistingTarget(s.gyfilter,tp,0,LOCATION_GRAVE,1,nil) then codes[#codes+1]=4 end
	local optstrs={}
	for _,cde in ipairs(codes) do optstrs[#optstrs+1]=aux.Stringid(id,cde+1) end
	local sel
	if #optstrs==1 then
		sel=0
	elseif #optstrs==2 then
		sel=Duel.SelectOption(tp,optstrs[1],optstrs[2])
	elseif #optstrs==3 then
		sel=Duel.SelectOption(tp,optstrs[1],optstrs[2],optstrs[3])
	else
		sel=Duel.SelectOption(tp,optstrs[1],optstrs[2],optstrs[3],optstrs[4])
	end
	sel=codes[sel+1]
	e:SetLabel(sel)
	if sel==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,s.atkfilter,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif sel==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectTarget(tp,s.stfilter,tp,0,LOCATION_SZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	elseif sel==4 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectTarget(tp,s.gyfilter,tp,0,LOCATION_GRAVE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
function s.selop(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	if sel==1 then
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	elseif sel==2 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
	elseif sel==3 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then Duel.SendtoGrave(tc,REASON_EFFECT) end
	elseif sel==4 then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then Duel.Remove(tc,POS_FACEUP,REASON_EFFECT) end
	end
end