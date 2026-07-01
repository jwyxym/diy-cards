--堕魔之焰 事象改写
function c38030126.initial_effect(c)
	c:SetSPSummonOnce(38030126)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFun(c,38030100,c38030126.ffilter,5,true,true)
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
	se0:SetCondition(c38030126.sprcon)
	--se0:SetTarget(c38030126.sprtg)
	se0:SetOperation(c38030126.sprop)
	c:RegisterEffect(se0)
	--[[--change code
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c38030126.codecon)
	e1:SetValue(38030102)
	c:RegisterEffect(e1)]]
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38030126,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,38030126)
	e1:SetCondition(c38030126.codecon)
	e1:SetTarget(c38030126.rmtg)
	e1:SetOperation(c38030126.rmop)
	c:RegisterEffect(e1)
	--change effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38030126,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,38030126)
	e2:SetCondition(c38030126.cecon)
	e2:SetTarget(c38030126.cetg)
	e2:SetOperation(c38030126.ceop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)--TIMING_END_PHASE
	e3:SetDescription(aux.Stringid(38030126,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,38030126+1)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c38030126.sptg)
	e3:SetOperation(c38030126.spop)
	c:RegisterEffect(e3)
	--counter
	Duel.AddCustomActivityCounter(38030126,ACTIVITY_SPSUMMON,c38030126.counterfilter)
end
function c38030126.counterfilter(c)
	return not c:IsCode(38030084)
end
function c38030126.ffilter(c,fc,sub,mg,sg)
	return c:IsType(TYPE_MONSTER) and c:IsFusionSetCard(0x615) and (not sg or not sg:Filter(Card.IsFusionSetCard,nil,0x615):IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
function c38030126.sprcon(e,c)
	if c==nil then return true end
	return Duel.GetCustomActivityCount(38030126,c:GetOwner(),ACTIVITY_SPSUMMON)>0
end
function c38030126.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function c38030126.codecon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function c38030126.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chk:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function c38030126.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
function c38030126.cecon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function c38030126.thfilter(c)
	return c:IsCode(38030102) and c:IsAbleToHand() and c:IsFaceup()
end
function c38030126.cetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,rp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
end
function c38030126.ceop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,c38030126.repop)
end
function c38030126.repop(e,tp,eg,ep,ev,re,r,rp)
	local p=tp
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
	local sg=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil)
	if sg:GetCount()>0 then
		Duel.HintSelection(sg)
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function c38030126.spfilter(c,e,tp)
	return not c:IsCode(38030126) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c38030126.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c38030126.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		and Duel.IsExistingTarget(c38030126.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c38030126.spfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c38030126.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c38030126.cccon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2--Duel.IsMainPhase()
end
function c38030126.tfilter(c)
	return c:IsFaceup() and not c:IsCode(38030102)
end
function c38030126.cctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c38030126.tfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c38030126.tfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,c38030126.tfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
function c38030126.ccop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(38030102)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
