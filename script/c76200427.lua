--龙母之玛莉龙忒转化
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.AddCodeList(c,76200403)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(this.target)
	e1:SetOperation(this.activate)
	c:RegisterEffect(e1)
end
function this.getLevel(c)
	if c:IsLocation(LOCATION_PZONE) then return c:GetOriginalLevel()
	else return c:GetLevel() end
end
function this.getRitualLevel(c,rc)
	if c:IsLocation(LOCATION_PZONE) then return c:GetOriginalLevel()
	else return c:GetRitualLevel(rc) end
end
function this.isRace(c,r)
	if c:IsLocation(LOCATION_PZONE) then return c:GetOriginalRace()&r~=0
	else return c:IsRace(r) end
end
function this.filter(c,e,tp)
	if not c:IsCode(76200403) or bit.band(c:GetType(),0x81)~=0x81
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	return Duel.IsExistingMatchingCard(this.matfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,c,e,tp,c)
end
function this.matfilter1(c,e,tp,rc)
	local g=Duel.GetRitualMaterial(tp):Filter(this.matfilter2,c,rc)
	if Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) then
		local g1=Duel.GetMatchingGroup(this.matfilter3,tp,LOCATION_PZONE,0,nil,e)
		g:Merge(g1)
	end
	local res
	if this.getLevel(c)<this.getLevel(rc) then
		res=g:CheckWithSumGreater(this.getRitualLevel,this.getLevel(rc)-this.getLevel(c),rc)
	else
		res=true
	end
	return c:IsType(TYPE_PENDULUM) and this.isRace(c,RACE_DRAGON) and c:IsReleasable() and c:IsCanBeRitualMaterial(rc)
	and res
end
function this.matfilter2(c,rc)
	return this.isRace(c,RACE_DRAGON) and c:IsReleasable() and c:IsCanBeRitualMaterial(rc)
end
function this.matfilter3(c,e)
	return not c:IsImmuneToEffect(e)
end
function this.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function this.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local rc=Duel.SelectMatchingCard(tp,this.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if rc then
		local mg=Duel.GetRitualMaterial(tp)
		if Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_MZONE,1,nil) then
			local g1=Duel.GetMatchingGroup(this.matfilter3,tp,LOCATION_PZONE,0,nil,e)
			mg:Merge(g1)
		end
		mg:RemoveCard(rc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local g1=mg:FilterSelect(tp,this.matfilter1,1,1,nil,e,tp,rc)
		mg:RemoveCard(g1:GetFirst())
		if this.getLevel(g1:GetFirst())<this.getLevel(rc) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local g2=mg:SelectWithSumGreater(tp,this.getRitualLevel,this.getLevel(rc)-this.getLevel(g1:GetFirst()),rc)
			g1:Merge(g2)
		end
		rc:SetMaterial(g1)
		Duel.Release(g1,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		Duel.BreakEffect()
		Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		rc:CompleteProcedure()
	end
end
