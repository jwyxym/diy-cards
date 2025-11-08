--绝大唯我·马塞班恩
local s,id,o=GetID()
function s.initial_effect(c)
	--超量召唤
	aux.AddXyzProcedure(c,nil,6,6,s.ovfilter,aux.Stringid(id,0),6,s.xyzop)
	c:EnableReviveLimit()
	--效果耐性      
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.imcon)
	e1:SetCost(s.imcost)
	e1:SetOperation(s.imop)
	c:RegisterEffect(e1)    
	--加入手卡    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--伤害并破坏    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
    e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)   
    Duel.AddCustomActivityCounter(id+o*2,ACTIVITY_CHAIN,s.chainfilter)
end    
function s.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_SPELL) and re:GetHandler():IsSetCard(0xacaa))
end
function s.ovfilter(c)
	return c:IsFaceup() and c:IsCode(31280237) and c:GetOverlayCount()==0
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id+o)==0 end
	Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.imcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler()~=e:GetHandler()
end
function s.cfilter(c)
	return c:IsSetCard(0xacaa) and not c:IsPublic()
end
function s.imcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
	local b2=Duel.GetCustomActivityCount(id+o*2,tp,ACTIVITY_CHAIN)>0
	if chk==0 then return b1 or b2 end
	if b1 then
		if b2 and not Duel.SelectYesNo(tp,aux.Stringid(id,4)) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end
function s.imop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(s.efilter)
		c:RegisterEffect(e1)
	end
end
function s.efilter(e,te)
	return not te:GetOwner():IsSetCard(0xacaa)
end
function s.thfilter(c,check)
	return c:IsSetCard(0xacaa) and c:IsAbleToHand() and (c:IsLocation(LOCATION_GRAVE) or check)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local check=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)==1
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil,check) end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local check=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)==1
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,check)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
end    
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end  
end
function s.desfilter(c)
	return c:IsFaceup() and (c:IsLevelBelow(6) or c:IsRankBelow(6))
end
function s.damfilter(c)
	return c:IsFaceup() and (c:IsLevelAbove(6) or c:IsRankAbove(6))
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_DECK,0)
	if g:GetCount()<1 then return end
	Duel.ConfirmCards(1-tp,g)
	if g:GetClassCount(Card.GetCode)==g:GetCount() then
    	local ct1=Duel.GetMatchingGroupCount(s.desfilter,tp,LOCATION_MZONE,0,nil)
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct1,nil)
		if dg:GetCount()>0 then
			Duel.HintSelection(dg)
			Duel.Destroy(dg,REASON_EFFECT)
        end
        local ct2=Duel.GetMatchingGroupCount(s.damfilter,tp,LOCATION_MZONE,0,nil)
        Duel.Damage(1-tp,ct2*1200,REASON_EFFECT)                
	end
end