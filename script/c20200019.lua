--爱丽丝，仙境的天使
function c20200019.initial_effect(c)
	c:SetSPSummonOnce(20200019)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c20200019.matfilter,1,1)
	--change code
	aux.EnableChangeCode(c,20200003,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_MZONE)
	--cannot link material
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
    e0:SetValue(1)
    c:RegisterEffect(e0)
	--spsummon1
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20200019,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1)
	e1:SetTarget(c20200019.sptg)
	e1:SetOperation(c20200019.spop)
	c:RegisterEffect(e1)
	--Special Summon (from hand : itself)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20200019,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCost(c20200019.spcost1)
	e2:SetTarget(c20200019.sptg1)
	e2:SetOperation(c20200019.spop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetRange(LOCATION_REMOVED)
	c:RegisterEffect(e3)
end
function c20200019.matfilter(c)
	return c:IsLinkSetCard(0xb31) and c:IsLevel(3)
end
function c20200019.filter(c,e,tp)
	return c:IsSetCard(0xb31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetMZoneCount(tp)>0 and (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()) or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 and c:IsFaceup()) or (c:IsLocation(LOCATION_PZONE) and c:IsFaceup())
end
function c20200019.sptg(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	if chk==0 then return Duel.IsExistingMatchingCard(c20200019.filter,tp,LOCATION_REMOVED+LOCATION_PZONE+LOCATION_EXTRA,0,1,exc,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED+LOCATION_PZONE+LOCATION_EXTRA)
end
function c20200019.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c20200019.filter,tp,LOCATION_REMOVED+LOCATION_PZONE+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c20200019.costfilter(c)
	return c:IsCode(20200003) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsAbleToRemoveAsCost()
end
function c20200019.mzfilter(c)
    return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
function c20200019.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local rg=Duel.GetMatchingGroup(c20200019.costfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,c)
    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    local ct=-ft+1
    if chk==0 then return ft>-2 and rg:GetCount()>1 and (ft>0 or rg:IsExists(c20200019.mzfilter,ct,nil)) end
    local g=nil
    if ft>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        g=rg:Select(tp,2,2,nil)
    elseif ft==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        g=rg:FilterSelect(tp,c20200019.mzfilter,1,1,nil)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local g2=rg:Select(tp,1,1,g:GetFirst())
        g:Merge(g2)
    else
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        g=rg:FilterSelect(tp,c20200019.mzfilter,2,2,nil)
    end
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c20200019.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c20200019.spop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end