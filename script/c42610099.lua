--春巫 艾露迪
local cm,m=GetID()

function cm.initial_effect(c)
    c:EnableCounterPermit(0x1)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_SPELLCASTER),2,3)
	c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --recover
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(cm.regcon)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
    --release
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m)
	e1:SetCost(cm.recost)
	e1:SetTarget(cm.retg)
	e1:SetOperation(cm.reop)
	c:RegisterEffect(e1)
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

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsRace,tp,0x10,0x10,nil,RACE_SPELLCASTER)
	if chk==0 then return #g>0 and e:GetHandler():IsCanAddCounter(0x1,#g) end
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToChain() then
        local g=Duel.GetMatchingGroup(Card.IsRace,tp,0x10,0x10,nil,RACE_SPELLCASTER)
        if #g>0 then
            c:AddCounter(0x1,#g)
        end
    end
end

function cm.costrfilter(c,lg)
    return lg:IsContains(c) and c:IsReleasable()
end

function cm.recost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	c:RemoveCounter(tp,0x1,3,REASON_COST)
end

function cm.tgrfilter(c)
    return c:GetAttack()>0 and c:IsFaceup()
end

function cm.retg(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(cm.tgrfilter,tp,0x04,0,1,nil) and Duel.GetCounter(0,1,1,0x1)>0
    local b2=Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0x0c,0,1,e:GetHandler(),0x1,3)
	if chk==0 then return b1 or b2 end
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(m,0)},
		{b2,aux.Stringid(m,1)})
	e:SetLabel(op)
    if op==1 then
        e:SetCategory(e:GetCategory()|CATEGORY_ATKCHANGE)
    elseif op==2 then
        e:SetCategory(e:GetCategory()|CATEGORY_COUNTER)
    end
end

function cm.reop(e,tp,eg,ep,ev,re,r,rp)
    local op,c=e:GetLabel(),e:GetHandler()
	if op==1 then
        local ct=Duel.GetCounter(0,1,1,0x1)
        if ct>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local g=Duel.SelectMatchingCard(tp,cm.tgrfilter,tp,0x04,0x04,1,1,nil)
            if #g>0 then
                Duel.HintSelection(g)
                local tc=g:GetFirst()
                local e1=Effect.CreateEffect(c)
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetRange(LOCATION_MZONE)
                e1:SetValue(ct*100)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                tc:RegisterEffect(e1)
                local e4=Effect.CreateEffect(c)
                e4:SetType(EFFECT_TYPE_FIELD)
                e4:SetCode(EFFECT_CANNOT_ACTIVATE)
                e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
                e4:SetTargetRange(0,1)
                e4:SetLabelObject(tc)
                e4:SetValue(cm.aclimit)
                e4:SetReset(RESET_PHASE+PHASE_END)
                Duel.RegisterEffect(e4,tp)
                tc:RegisterFlagEffect(0,RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(m,2))
            end
        end
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
        local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,0x0c,0,1,1,c,0x1,3)
        if #g>0 then
            Duel.HintSelection(g)
            g:GetFirst():AddCounter(0x1,3)
        end
	end
end

function cm.aclimit(e,re,tp)
	return re:GetHandler()==e:GetLabelObject() and re:IsActiveType(TYPE_MONSTER)
end