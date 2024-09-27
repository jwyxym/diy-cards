--原初魔女 蓝莓
local cm,m=GetID()

function cm.initial_effect(c)
    c:EnableCounterPermit(0x1)
    --
    aux.AddLinkProcedure(c,nil,3,5,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(cm.regcon)
    e2:SetCost(cm.thcost)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
    --release
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_COUNTER+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,m)
	e1:SetCost(cm.recost)
	e1:SetTarget(cm.retg)
	e1:SetOperation(cm.reop)
	c:RegisterEffect(e1)
end

function cm.lcheck(g)
	return g:IsExists(Card.IsCode,1,nil,42610093)
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

function cm.costtfilter(c,g)
	return c:IsDiscardable() and g:IsExists(aux.TRUE,1,c)
end

function cm.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(cm.tgsfilter,tp,LOCATION_HAND,0,nil,e,tp,e:GetHandler():GetLinkedZone())
	if chk==0 then return Duel.IsExistingMatchingCard(cm.costtfilter,tp,LOCATION_HAND,0,1,nil,g) end
	Duel.DiscardHand(tp,cm.costtfilter,1,1,REASON_COST+REASON_DISCARD,nil,g)
end

function cm.tgsfilter(c,e,tp,zone)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone) and c:IsRace(RACE_SPELLCASTER)
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local zone=e:GetHandler():GetLinkedZone()
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tgsfilter,tp,LOCATION_HAND,0,1,nil,e,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local zone=c:GetLinkedZone()
    if not Duel.IsExistingMatchingCard(cm.tgsfilter,tp,LOCATION_HAND,0,1,nil,e,tp,zone) then return false end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cm.tgsfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone)
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone) then
        local tc=g:GetFirst()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(400)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1,true)
	end
end

function cm.costrfilter(c)
    return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end

function cm.recost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.costrfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,cm.costrfilter,1,1,REASON_COST+REASON_DISCARD)
end

function cm.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0x04,0,1,nil) and e:GetHandler():IsCanAddCounter(0x1,3) end
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end

function cm.reop(e,tp,eg,ep,ev,re,r,rp)
    local g,c=Duel.GetMatchingGroup(Card.IsFaceup,tp,0x04,0,nil),e:GetHandler()
    if #g>0 then
        for tc in aux.Next(g) do
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetRange(LOCATION_MZONE)
            e1:SetValue(400)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
    Duel.Recover(tp,500,REASON_EFFECT)
    if c:IsRelateToChain() then
        c:AddCounter(0x1,3)
    end
end