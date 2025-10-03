local m=41801006
local cm=_G["c"..m]
cm.name="天底弃械//猎龙"
local s,id=GetID()
function cm.initial_effect(c)
	--synchro summon
	aux.AddSynchroMixProcedure(c,cm.filter,nil,nil,aux.FilterBoolFunction(Card.IsRace,RACE_WYRM),1,99)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetCode(EFFECT_CANNOT_REMOVE)
	e0:SetTargetRange(1,1)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTarget(cm.efilter)
	c:RegisterEffect(e0)

	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m)
	e1:SetCondition(cm.discon)
	e1:SetTarget(cm.distg)
	e1:SetOperation(cm.disop)
	c:RegisterEffect(e1)
	--同调召唤的这张卡被破坏时从额外卡组特殊召唤同名怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function cm.efilter(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsFaceup() and c:IsControler(tp) and (c:IsSetCard(0x5410)or c:IsCode(96570609,95457011,1984618))
	and c:IsLocation(LOCATION_ONFIELD) and re and r&REASON_EFFECT>0 and rp==1-tp
end

function cm.filter(c)
	return c:IsType(TYPE_TUNER)
end
function cm.desfilter(c)
	return (c:IsSetCard(0x5410)or c:IsCode(96570609,95457011,1984618)) and c:IsFaceupEx()
end
function cm.discon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
	and rp==1-tp and Duel.IsChainDisablable(ev)
	and (bit.band(loc,LOCATION_HAND)~=0 or re:GetHandler():IsStatus(STATUS_ACT_FROM_HAND))
	and re:IsActiveType(TYPE_MONSTER+TYPE_TRAP)
end
function cm.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function cm.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		if re:GetHandler():IsRelateToEffect(re) then
			Duel.SendtoDeck(eg,nil,2,REASON_EFFECT)
		end
		if  Duel.IsExistingMatchingCard(cm.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g=Duel.SelectMatchingCard(tp,cm.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
			if g:GetCount()>0 then
				Duel.HintSelection(g)
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT+REASON_BATTLE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
