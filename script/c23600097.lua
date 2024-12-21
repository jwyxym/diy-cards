--同阶迁移-双子座
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddXyzProcedure(c,s.matfilter,9,4)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.operation)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)									
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.rscon)				
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon2)
	e4:SetCost(s.spcost2)
	e4:SetTarget(s.sptg2)
	e4:SetOperation(s.spop2)
	c:RegisterEffect(e4)
end
function s.matfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsCode(23600081)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_WITHOUT_TEMP_REMOVE,0,1)
end
function s.rscon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:GetFlagEffect(id)>0
end
function s.cfilter(c)
	return c:IsCode(23600096)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(s.cfilter,1,nil)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.filter1(c,e,tp)
	return c:IsFaceupEx() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter2(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
function s.fselect(sg,tp,ec)
	local mg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
	mg:Merge(sg)
	return mg:CheckSubGroup(s.matfilter,1,#mg,tp,sg)
		and ec:CheckRemoveOverlayCard(tp,sg:GetCount(),REASON_COST)
end
function s.matfilter(sg,tp,g)
	return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,sg)
end
function s.xyzfilter(c,mg)
	return c:IsSetCard(0xd80) and c:IsXyzSummonable(mg,#mg,#mg)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		return Duel.IsPlayerCanSpecialSummonCount(tp,2)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and mg:CheckSubGroup(s.fselect,1,ft,tp,e:GetHandler())
	end
	local cct=e:GetHandler():RemoveOverlayCard(tp,1,ct,REASON_COST)
	e:SetLabel(cct)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local cct=e:GetLabel()
	if cct>ft then return end
	if ft>cct then ft=cct end
	if not Duel.IsPlayerCanSpecialSummonCount(tp,2) or ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local mg=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=mg:SelectSubGroup(tp,s.fselect,false,1,ft,tp,e:GetHandler())
	if not g then return end
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
	Duel.SpecialSummonComplete()
	Duel.AdjustAll()
	if g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<#g then return end
	local exg=Duel.GetMatchingGroup(s.xyzfilter2,tp,LOCATION_EXTRA,0,nil)
	local xyzg=exg:Filter(s.ovfilter,nil,tp,g)
	if xyzg:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		local fg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
		local sg=fg:SelectSubGroup(tp,s.gselect,false,1,7,xyz,g)
		Duel.XyzSummon(tp,xyz,sg)
	end
end
function s.xyzfilter2(c)
	return c:IsSetCard(0xd80)
end
function s.ovfilter(c,tp,sg)
	local mg=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,0,nil)
	mg:Merge(sg)
	return mg:CheckSubGroup(s.gselect,1,#mg,c,sg)
end
function s.gselect(sg,c,g)
	return c:IsXyzSummonable(sg,#sg,#sg)
end
function s.ccfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xd80) and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsControler(tp)
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	Debug.Message(3)
	return eg:IsExists(s.ccfilter,1,nil,tp)
end
function s.spcfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	Debug.Message(2)
	if chk==0 then return true end
end
function s.sovfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_XYZ)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		Debug.Message(1)
		if e:GetLabel()~=100 then return false end
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
			and Duel.IsExistingMatchingCard(s.sovfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler())
	end
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_MZONE,0,nil)
	local xg=Group.FromCards()
	for tc in aux.Next(g) do
		if tc:GetOverlayCount()>0 then
			for xc in aux.Next(tc:GetOverlayGroup()) do
				xg:AddCard(xc)
			end
		end
	end
	local ct=Duel.GetMatchingGroupCount(s.sovfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,e:GetHandler())
	local rg=xg:Select(tp,1,ct,nil)
	local rct=Duel.SendtoGrave(rg,REASON_COST)
	e:SetLabel(rct)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local rg=Duel.SelectMatchingCard(tp,s.sovfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,e:GetLabel(),e:GetLabel(),e:GetHandler())
		if rg:GetCount()>0 then
			Duel.Overlay(c,rg)
		end
	end
end