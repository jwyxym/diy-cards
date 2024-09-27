--盾之勇者成名录 拉芙塔莉雅
local cm,m=GetID()

function cm.initial_effect(c)
	aux.AddCodeList(c,10700521)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,0xc200),2,2)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --disable
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE+CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,m)
    e2:SetCondition(cm.thcon)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
    --disable
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,m+1)
    e3:SetCost(aux.bfgcost)
	e3:SetTarget(cm.htg)
	e3:SetOperation(cm.hop)
	c:RegisterEffect(e3)
end

function cm.regcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetSummonType(),SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(cm.splimit)
	Duel.RegisterEffect(e1,tp)
end

function cm.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(m) and bit.band(sumtype,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end

function cm.contfilter(c,tp)
    return c:IsPreviousLocation(0x04) and c:GetReasonPlayer()==1-tp
end

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cm.contfilter,1,nil,tp)
end

function cm.tgtfilter(c)
    return (aux.NegateMonsterFilter(c) and c:IsLocation(0x04)) or (c:IsLocation(0x08) and c:IsAbleToRemove())
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,0x08)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,0x08)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,0x04)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local off=1
	local ops={}
	local opval={}
	if Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,0x04,1,nil) then
		ops[off]=aux.Stringid(m,0)
		opval[off-1]=1
		off=off+1
	end
	if Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,0x08,1,nil) then
		ops[off]=aux.Stringid(m,1)
		opval[off-1]=2
		off=off+1
	end
	if c:IsRelateToEffect(e) then
		ops[off]=aux.Stringid(m,2)
		opval[off-1]=3
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=Duel.SelectMatchingCard(tp,aux.NegateMonsterFilter,tp,0,0x04,1,1,nil)
        local tc=g:GetFirst()
		Duel.HintSelection(g)
		if tc and tc:IsCanBeDisabledByEffect(e) then
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_CANNOT_ATTACK)
            e3:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e3)
		end
	elseif opval[op]==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,0x08,1,1,nil)
        if #g>0 then
            Duel.HintSelection(g)
            Duel.Destroy(g,REASON_EFFECT,LOCATION_REMOVED)
        end
	elseif opval[op]==3 then
		local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
	end
end

function cm.tghfilter(c)
    return c:IsAbleToHand() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(0xc200)
end

function cm.htg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.tghfilter,tp,0x10,0,1,e:GetHandler()) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0x10)
end

function cm.hop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g=Duel.SelectMatchingCard(tp,cm.tghfilter,tp,0x10,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
		if g:GetFirst():IsLocation(0x02) then
			Duel.ConfirmCards(1-tp,g)
		end
    end
end