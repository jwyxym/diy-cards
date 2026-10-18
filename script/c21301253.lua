--断破银辉
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	--回到卡组
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.tdcost)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)   
end
function s.confilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x684) or (c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON)))
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsChainDisablable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
function s.desfilter(c,s,tp)
	local seq=c:GetSequence()
	return seq<5 and math.abs(seq-s)==1 and c:IsControler(tp)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) and rc:IsOnField() then
    	local seq=rc:GetSequence()
        local loc
        if rc:IsLocation(LOCATION_MZONE) then loc=LOCATION_MZONE
        elseif rc:IsLocation(LOCATION_SZONE) then loc=LOCATION_SZONE end
   		local sg=Duel.GetMatchingGroup(s.desfilter,tp,loc,loc,nil,seq,rc:GetControler()) 
    	sg:AddCard(rc)
        if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        	Duel.BreakEffect()
            Duel.Destroy(sg,REASON_EFFECT)
        end
	end
end
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeckAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,2,REASON_COST)    
    Duel.ConfirmCards(1-tp,e:GetHandler())
end
function s.tdfilter(c)
	return c:IsSetCard(0x684) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,tdfilter)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,3,nil)
	if g:GetCount()>0 then
    	Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	end
end