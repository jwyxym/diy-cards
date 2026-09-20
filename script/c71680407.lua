--凯旋的四方主
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetTarget(s.zonetg)
	e1:SetOperation(s.zoneop)
	c:RegisterEffect(e1)
	--act in hand
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1,id)
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE,PLAYER_NONE,0)>0 and  c:GetSequence()>4
end
function s.zonetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.zoneop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or Duel.GetLocationCount(tc:GetControler(),LOCATION_MZONE,PLAYER_NONE,0)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	if tc:IsControler(tp) then
		local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
		Duel.Hint(HINT_ZONE,tp,fd)
		local seq=math.log(fd,2)
		Duel.MoveSequence(tc,seq)
	else
		local fd=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,0)
		Duel.Hint(HINT_ZONE,tp,fd)
		local nseq=math.log(bit.rshift(fd,16),2)
		Duel.MoveSequence(tc,nseq)
	end
	Duel.BreakEffect()
	local g=nil
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then
		g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	end
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)==0 then
		g:Merge(Duel.GetMatchingGroup(aux.TRUE,1-tp,LOCATION_MZONE,0,nil))
	end
	if g and #g~=0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.hcfilter(c)
	return c:IsFaceup() and c:GetSequence()>4 and c:IsSetCard(0x597)
end
function s.handcon(e)
	return Duel.IsExistingMatchingCard(s.hcfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.spfilter(c)
	return c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,e:GetHandler())
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,tp,REASON_EFFECT)
	end
end