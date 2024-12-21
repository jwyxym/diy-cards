--花之使 蔓珠沙华
function c72600036.initial_effect(c)
	c:SetUniqueOnField(1,0,72600036)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),1)
	c:EnableReviveLimit()
	--to deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c72600036.tdcon)
	e1:SetTarget(c72600036.tdtg)
	e1:SetOperation(c72600036.tdop)
	c:RegisterEffect(e1)
	--Activate(effect)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c72600036.condition)
	e2:SetCost(c72600036.cost)
	e2:SetTarget(c72600036.target)
	e2:SetOperation(c72600036.operation)
	c:RegisterEffect(e2)
end
function c72600036.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c72600036.tdfilter(c,e)
	return c:IsRace(RACE_PLANT) and c:IsAbleToDeck()
		and (not e or c:IsCanBeEffectTarget(e))
end

function c72600036.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c72600036.tdfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c72600036.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.GetMatchingGroup(c72600036.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e)
	aux.GCheckAdditional=aux.dncheck
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,1,#g)
	aux.GCheckAdditional=nil
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,#sg,0,0)
end
function c72600036.spfilter(c,e,tp,ct)
	return c:IsRace(RACE_PLANT) and c:IsLevelBelow(e:GetLabel()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c72600036.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
	local cg=Duel.GetOperatedGroup()
	local ct=cg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)
	e:SetLabel(ct)
	if ct>0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local vg=Duel.GetMatchingGroup(c72600036.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		if vg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(72600036,1)) then
		   Duel.BreakEffect()
		   Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		   local sg=vg:Select(tp,1,1,nil)
		   Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function c72600036.condition(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function c72600036.cfilter(c)
	return c:IsRace(RACE_PLANT)
end
function c72600036.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,c72600036.cfilter,1,REASON_COST,true,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectReleaseGroupEx(tp,c72600036.cfilter,1,1,REASON_COST,true,nil,tp)
	Duel.Release(g,REASON_COST)
	local dc=Duel.GetOperatedGroup():GetFirst()
	if dc:IsSetCard(0x726) then e:SetLabel(1)
	else e:SetLabel(0) end
end
function c72600036.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sel=e:GetLabel()
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
	if sel==1 then e:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	else e:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY) end
end
function c72600036.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	local sel=e:GetLabel()
	if not Duel.NegateActivation(ev) then return end
	if rc:IsRelateToEffect(re) and not (rc:IsLocation(LOCATION_DECK) or rc:IsLocation(LOCATION_REMOVED) and rc:IsFacedown()) and Duel.Destroy(eg,REASON_EFFECT)~=0 and sel==1 and aux.NecroValleyFilter()(rc) then
		if rc:IsType(TYPE_MONSTER) and (not rc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				or rc:IsLocation(LOCATION_EXTRA) and rc:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,rc)>0)
			and rc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
			and Duel.SelectYesNo(tp,aux.Stringid(72600036,2)) then
			Duel.BreakEffect()
			Duel.SpecialSummon(rc,0,tp,tp,false,false,POS_FACEUP)
		end
		rc:CompleteProcedure()
		local e1=Effect.CreateEffect(re:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_PLANT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
	end
end