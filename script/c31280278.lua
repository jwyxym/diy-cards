--永枢黯锷 午夜对谈
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
	e1:SetTarget(s.cptg)
	e1:SetOperation(s.cpop)
	c:RegisterEffect(e1)
	--盖放
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o*10000)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
function s.cpfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x6ca0) and c:IsType(TYPE_MONSTER) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
    	and c:IsAbleToRemoveAsCost()) then return false end
	local te=c.machine_fiend_be_remove_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		and Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp):GetFirst()
	local te=tc.machine_fiend_be_remove_effect
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty())
	Duel.ClearTargetCard()
	e:SetLabelObject(te)
	local tg=te:GetTarget()
	if tg then
		local cchk=e:IsCostChecked()
		e:SetCostCheck(false)
		tg(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetCostCheck(cchk)
	end
	Duel.ClearOperationInfo(0)
    local ch=Duel.GetCurrentChain()
    local te,loc=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_LOCATION)
	if ch>1 and loc&LOCATION_HAND>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) then
        e:SetCategory(CATEGORY_DISABLE)        
    end
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local op=te:GetOperation()
	if op then 
    	op(e,tp,eg,ep,ev,re,r,rp) 
    end
    local ch=Duel.GetCurrentChain()
    local te,loc=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_LOCATION)
	if ch>1 and loc&LOCATION_HAND>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainDisablable(ch-1) 
    	and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
    	Duel.BreakEffect()
    	Duel.NegateEffect(ch-1)
    end
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_GRAVE)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then 
    	Duel.SSet(tp,e:GetHandler())
    end
end