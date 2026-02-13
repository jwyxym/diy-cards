--
function c19990045.initial_effect(c)
	c:SetSPSummonOnce(19990045)
	c:SetUniqueOnField(1,0,19990045)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunFunRep(c,c19990045.mfilter,aux.FilterBoolFunction(Card.IsFusionSetCard,0xb29),2,2,true)
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c19990045.efilter)
	c:RegisterEffect(e1)
	--Set Quick or Trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19990045,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetCountLimit(1)
	e2:SetTarget(c19990045.settg)
	e2:SetOperation(c19990045.setop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19990045,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,19990045)
	e3:SetCost(c19990045.spcost)
	e3:SetTarget(c19990045.sptg)
	e3:SetOperation(c19990045.spop)
	c:RegisterEffect(e3)
end
function c19990045.mfilter(c)
	return c:IsSetCard(0xb29) and c:IsFusionType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
end
function c19990045.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function c19990045.setfilter(c)
	return c:IsSetCard(0xb30) and c:IsSSetable()
		and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD)
end
function c19990045.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19990045.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function c19990045.setop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	if ft>=3 then ft=3 end
	local g=Duel.GetMatchingGroup(c19990045.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
		if sg:GetCount()>0 then
			Duel.SSet(tp,sg)
		end
	end
end
function c19990045.cfilter(c)
	return c:IsSetCard(0xb30) or c:IsSetCard(0xb29) and c:IsAbleToRemoveAsCost()
end
function c19990045.mzfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
function c19990045.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(c19990045.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	if chk==0 then return ft>-4 and rg:GetCount()>1 and (ft>0 or rg:IsExists(c19990045.mzfilter,ct,nil)) end
	local g=nil
	if ft>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=rg:Select(tp,4,4,nil)
	elseif ft==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=rg:FilterSelect(tp,c19990045.mzfilter,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g2=rg:Select(tp,1,1,g:GetFirst())
		g:Merge(g2)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		g=rg:FilterSelect(tp,c19990045.mzfilter,4,4,nil)
	end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c19990045.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c19990045.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end