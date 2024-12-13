--召唤魔龙的龙巫女
function c19000026.initial_effect(c)
	c:SetUniqueOnField(1,0,19000026)
	--xyz summon
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,c19000026.mfilter,nil,2,99)
	--spsummon1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19000026,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,19000026)
	e1:SetCost(c19000026.spcost)
	e1:SetTarget(c19000026.sptg)
	e1:SetOperation(c19000026.spop)
	c:RegisterEffect(e1)
	--spsmmon2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19000026,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+19000026)
	e2:SetCountLimit(1,19000026+100)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c19000026.condition)
	e2:SetTarget(c19000026.target)
	e2:SetOperation(c19000026.operation)
	c:RegisterEffect(e2)
	if not c19000026.global_check then
		c19000026.global_check=true
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c19000026.regcon)
		ge1:SetOperation(c19000026.regop)
		Duel.RegisterEffect(ge1,0)
	end
end
function c19000026.mfilter(c,xyzc)
	return c:IsXyzLevel(xyzc,10) or (c:IsType(TYPE_LINK) and (c:IsLinkMarker(LINK_MARKER_LEFT) or c:IsLinkMarker(LINK_MARKER_RIGHT)) and (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_DRAGON)))
end
function c19000026.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetOverlayCount()
	if chk==0 then return ct>0 and c:CheckRemoveOverlayCard(tp,ct,REASON_COST) end
	c:RemoveOverlayCard(tp,ct,ct,REASON_COST)
end
function c19000026.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsLinkBelow(3) and (c:IsLinkMarker(LINK_MARKER_LEFT) or c:IsLinkMarker(LINK_MARKER_RIGHT)) and (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_DRAGON)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_LINK,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c19000026.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		and Duel.IsExistingMatchingCard(c19000026.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c19000026.spop(e,tp,eg,ep,ev,re,r,rp)
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c19000026.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	if Duel.SpecialSummon(tc,SUMMON_TYPE_LINK,tp,tp,false,false,POS_FACEUP)~=0 then
	    tc:CompleteProcedure()
    end
end
function c19000026.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp)
end
function c19000026.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c19000026.spcfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c19000026.spcfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
function c19000026.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RaiseEvent(eg,EVENT_CUSTOM+19000026,re,r,rp,ep,e:GetLabel())
end
function c19000026.condition(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
function c19000026.filter(c,e,tp)
	return (c:IsAttribute(ATTRIBUTE_FIRE) or c:IsRace(RACE_DRAGON)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c19000026.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19000026.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function c19000026.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c19000026.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end