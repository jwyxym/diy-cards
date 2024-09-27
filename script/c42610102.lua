--春巫 摩卡莫莉
local cm,m=GetID()

function cm.initial_effect(c)
	c:EnableCounterPermit(0x1)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_SPELLCASTER),2,4)
	c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --attackup
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(cm.atkval)
    c:RegisterEffect(e1)
    --release
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,m)
	e2:SetCost(cm.recost)
	e2:SetTarget(cm.retg)
	e2:SetOperation(cm.reop)
	c:RegisterEffect(e2)
    --count
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,m+1)
	e3:SetCondition(cm.descon)
	e3:SetCost(cm.descost)
	e3:SetTarget(cm.destg)
	e3:SetOperation(cm.desop)
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

function cm.atkval(e)
    return Duel.GetCounter(e:GetHandlerPlayer(),1,0,0x1)*200
end

function cm.costrfilter(c)
    return c:IsType(0x2) and c:IsAbleToDeck()
end

function cm.recost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,1,REASON_COST) end
    local max=1
    for i = 5, 1, -1 do
        if Duel.IsCanRemoveCounter(tp,1,0,0x1,i,REASON_COST) and Duel.IsExistingMatchingCard(cm.costrfilter,tp,0x10,0,i,nil) then
            max=i
            break
        end
    end
    local rm=1
    if max~=1 then
        rm=Duel.AnnounceNumber(tp,1,max)
    end
	Duel.RemoveCounter(tp,1,0,0x1,rm,REASON_COST)
    e:SetLabel(rm)
end

function cm.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.costrfilter,tp,0x10,0,1,nil) end
    local ct=e:GetLabel()
    if ct==5 then
        e:SetCategory(CATEGORY_DRAW|e:GetCategory())
        Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,ct,tp,0x10)
end

function cm.reop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,cm.costrfilter,tp,0x10,0,1,e:GetLabel(),nil)
    if #g>0 then
        Duel.HintSelection(g)
        if Duel.SendtoDeck(g,nil,2,REASON_EFFECT) then
            local og=Duel.GetOperatedGroup()
            if #og==5 then
                Duel.Draw(tp,1,REASON_EFFECT)
            end
        end
    end
end

function cm.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsCode(m)
end

function cm.costdfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end

function cm.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.costdfilter,tp,0x0a,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,cm.costdfilter,tp,0x0a,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end

function cm.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0x0c,0,1,nil,0x1,3) end
end

function cm.desop(e,tp,eg,ep,ev,re,r,rp,chk)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
    local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,0x0c,0,1,1,nil,0x1,3)
    if #g>0 then
        Duel.HintSelection(g)
        g:GetFirst():AddCounter(0x1,3)
    end
end