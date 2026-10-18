--惨烈的剑王·罗德诺艾尔四世
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,57320080)
	--连接召唤
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),2,3,s.lcheck)
	c:EnableReviveLimit()
	--赋予效果    
    local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.efcon)
    e1:SetCost(s.efcost)
	e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
	--加入手卡    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsSummonLocation,1,nil,LOCATION_EXTRA)
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.costfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToRemoveAsCost()
end
function s.efcost(e,tp,eg,ep,ev,re,r,rp,chk)
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
function s.tgfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	local g
	if e:GetLabel()==100 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,2,nil)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()<=0 then return end
    for i=1,sg:GetCount() do
		local b1=Duel.GetFlagEffect(tp,id)==0
    	local b2=Duel.GetFlagEffect(tp,id+o)==0
    	if not b1 and not b2 then break end
        local sc=sg:GetFirst()
    	if sg:GetCount()>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
            sc=sg:Select(tp,1,1,nil):GetFirst()
            if sc then
            	Duel.HintSelection(Group.FromCards(sc))
            end
    	end
        local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3),1},
			{b2,aux.Stringid(id,4),2})
        if op==1 then
        	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
			--不能作为对象        
        	local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
			e1:SetRange(LOCATION_MZONE)			
			e1:SetValue(aux.tgoval)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			--攻击力上升            
            local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetRange(LOCATION_MZONE)
			e2:SetTargetRange(LOCATION_MZONE,0)
			e2:SetTarget(s.atktg)
			e2:SetValue(1000)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e2)
            sc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,5))
        elseif op==2 then
        	Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
			--无效
        	local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(id,6))
			e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
			e3:SetType(EFFECT_TYPE_QUICK_O)
			e3:SetCode(EVENT_CHAINING)
			e3:SetRange(LOCATION_MZONE)
			e3:SetCountLimit(1)
			e3:SetCondition(s.discon)
            e3:SetCost(s.discost)
			e3:SetTarget(s.distg)
			e3:SetOperation(s.disop)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e3)
         	sc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,6))       
        end
        sg:RemoveCard(sc)
	end
end
function s.atktg(e,c)
	return c:IsRace(RACE_WARRIOR)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainDisablable(ev) and ep==1-tp and re:IsActiveType(TYPE_MONSTER)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
    end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function s.thfilter(c)
	return aux.IsCodeListed(c,57320080) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
    	and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end