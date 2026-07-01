--圆环之理 魂契救赎
function c38030124.initial_effect(c)
	c:SetSPSummonOnce(38030124)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,38030102,c38030124.ffilter,5,true,true)
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	--spsummon
	local se0=Effect.CreateEffect(c)
	se0:SetType(EFFECT_TYPE_FIELD)
	se0:SetCode(EFFECT_SPSUMMON_PROC)
	se0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	se0:SetRange(LOCATION_EXTRA)
	--se0:SetValue(SUMMON_TYPE_FUSION)
	se0:SetCondition(c38030124.sprcon)
	se0:SetTarget(c38030124.sprtg)
	se0:SetOperation(c38030124.sprop)
	c:RegisterEffect(se0)
	--to deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38030124,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,38030124)
	e1:SetCondition(c38030124.tdcon)
	e1:SetTarget(c38030124.tdtg)
	e1:SetOperation(c38030124.tdop)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)--TIMING_END_PHASE
	e2:SetDescription(aux.Stringid(38030124,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38030124+1)
	e2:SetCondition(c38030124.spcon)
	e2:SetTarget(c38030124.sptg)
	e2:SetOperation(c38030124.spop)
	c:RegisterEffect(e2)
	--immune
	local e3=Effect.CreateEffect(c)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetDescription(aux.Stringid(38030124,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c38030124.tdcon)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c38030124.immtg)
	e3:SetOperation(c38030124.immop)
	c:RegisterEffect(e3)
	--[[local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c38030124.tdcon)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x614,0x615))
	e3:SetValue(c38030124.efilter)
	c:RegisterEffect(e3)]]
	--counter
	Duel.AddCustomActivityCounter(38030124,ACTIVITY_SPSUMMON,c38030124.counterfilter)
end
function c38030124.counterfilter(c)
	return not c:IsCode(38030082)
end
function c38030124.ffilter(c,fc,sub,mg,sg)
	return c:IsType(TYPE_MONSTER) and c:IsFusionSetCard(0x614) and (not sg or not sg:Filter(Card.IsFusionSetCard,nil,0x614):IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
function c38030124.matfilter(c)
	return c:IsFusionCode(38030082) and c:IsReleasable(REASON_SPSUMMON) and c:IsCanBeFusionMaterial()
end
function c38030124.gcheck(mg,tp,fc)
	return Duel.GetLocationCountFromEx(tp,tp,mg,fc)>0
end
function c38030124.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetOwner()
	local mg=Duel.GetMatchingGroup(c38030124.matfilter,tp,LOCATION_MZONE,0,nil)
	return #mg>0 and Duel.GetCustomActivityCount(38030124,tp,ACTIVITY_SPSUMMON)>0
end
function c38030124.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local mg=Duel.GetMatchingGroup(c38030124.matfilter,tp,LOCATION_MZONE,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=mg:SelectSubGroup(tp,c38030124.gcheck,true,1,1,tp,c)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function c38030124.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=e:GetLabelObject()
	c:SetMaterial(mg)
	Duel.Release(mg,REASON_COST+REASON_MATERIAL)
	mg:DeleteGroup()
end
function c38030124.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c38030124.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function c38030124.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function c38030124.spcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2--Duel.IsMainPhase()
end
function c38030124.spfilter(c,e,tp,chk)
	return c:IsSetCard(0x614,0x615) and c:IsLevelBelow(11) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and (chk==0 or aux.NecroValleyFilter()(c))-- and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function c38030124.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0
		and Duel.IsExistingMatchingCard(c38030124.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,0)
	end--Duel.IsPlayerAffectedByEffect(tp,59822133)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c38030124.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,c38030124.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,1):GetFirst()
	if sc then
		Duel.SpecialSummon(sc,0,tp,tp,true,false,POS_FACEUP)
	end
end
function c38030124.immtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,38030124)==0 end
end
function c38030124.immop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,38030124,RESET_PHASE+PHASE_END,0,1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x614,0x615))
	e1:SetValue(c38030124.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c38030124.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
--[[function c38030124.efilter(e,te,ev)
	return not te:GetHandler():IsSetCard(0x614,0x615) and te:IsActivated()
end]]
