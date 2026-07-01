--魂之灵升变 佐仓杏子
function c38030111.initial_effect(c)
	--change name
	aux.EnableChangeCode(c,38030062,LOCATION_MZONE+LOCATION_GRAVE)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38030111,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,38030111)
	e1:SetCost(c38030111.spcost)
	e1:SetTarget(c38030111.sptg)
	e1:SetOperation(c38030111.spop)
	c:RegisterEffect(e1)
	--Inactivate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030111,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c38030111.discon)
	--e2:SetCost(c38030111.discost)
	e2:SetTarget(c38030111.distg)
	e2:SetOperation(c38030111.disop)
	c:RegisterEffect(e2)
end
function c38030111.costfilter(c)
	return c:IsCode(38030062,38030074) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
function c38030111.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c38030111.costfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c38030111.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function c38030111.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,SUMMON_VALUE_SELF,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c38030111.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
	end
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetTargetRange(1,0)
	e0:SetTarget(c38030111.splimit)
	e0:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e0,tp)
end
function c38030111.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not (c:IsRace(RACE_SPELLCASTER+RACE_FAIRY+RACE_FIEND) and c:IsLevelAbove(1))-- and c:IsLocation(LOCATION_EXTRA)
end
function c38030111.discon(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LEVEL)
	return ep~=tp and re:GetHandler():IsLevelAbove(1) and lv<=3 and Duel.IsChainDisablable(ev)
end
function c38030111.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,e:GetHandler(),RACE_FISH) end
	local sg=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,e:GetHandler(),RACE_FISH)
	Duel.Release(sg,REASON_COST)
end
function c38030111.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c38030111.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
