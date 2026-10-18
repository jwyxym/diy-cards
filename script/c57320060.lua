--天剑赐予
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,57320080)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--盖放
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon1)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)    
    local e3=e2:Clone()
	e3:SetCode(EVENT_LEAVE_GRAVE)
    e3:SetCondition(s.setcon2)
	c:RegisterEffect(e3)    
end
function s.costfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToRemoveAsCost()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local b=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil)
	if chk==0 then return true end
    e:SetLabel(0)
    if b and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_COST)
        e:SetLabel(100)
    end    
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    local ch=Duel.GetCurrentChain()
    local p,te=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)    
    if e:GetLabel()==100 and ch>1 and p==1-tp and e:IsHasType(EFFECT_TYPE_ACTIVATE)
    	and te and te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then
    	e:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
    else
    	e:SetCategory(0)
    end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.bdtg)
	e1:SetValue(800)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	Duel.RegisterEffect(e2,tp)
	local ch=Duel.GetCurrentChain()
    local p,te=Duel.GetChainInfo(ch-1,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_EFFECT)    
    if e:GetLabel()==100 and ch>1 and p==1-tp and e:IsHasType(EFFECT_TYPE_ACTIVATE)
    	and te and te:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainDisablable(ch-1)
    	and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.BreakEffect()
        if Duel.NegateEffect(ch-1) and te:GetHandler():IsRelateToEffect(te) then
			Duel.Destroy(te:GetHandler(),REASON_EFFECT)
		end
    end
end
function s.bdtg(e,c)
	return c:IsRace(RACE_WARRIOR)
end
function s.cfilter1(c,tp)
	return aux.IsCodeListed(c,57320080) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:GetReasonPlayer()==1-tp
end
function s.setcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter1,1,nil,tp)
end
function s.cfilter2(c,tp)
	return aux.IsCodeListed(c,57320080) and c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function s.setcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,tp)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SSet(tp,c)
	end
end