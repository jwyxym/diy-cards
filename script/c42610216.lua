--无能力者 柊娜娜
local cm,m=GetID()

function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --Normal monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_REMOVE_TYPE)
	e1:SetRange(0x44)
	e1:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e2)
    --
    local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(0x04)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(2)
	e3:SetTarget(cm.eftg)
	e3:SetOperation(cm.efop)
	c:RegisterEffect(e3)
    --cannot be target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(cm.tgcon)
	e4:SetValue(aux.imval1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_NORMAL)
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

function cm.tgefilter(c)
    return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end

function cm.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(0x04) and chkc:IsControler(tp) and cm.tgefilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(cm.tgefilter,tp,0x04,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    Duel.SelectTarget(tp,cm.tgefilter,tp,0x04,0,1,1,nil)
end

function cm.efop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToChain() and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_BATTLE_DESTROYING)
        e1:SetRange(0x04)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        e1:SetCondition(cm.effcon1)
        e1:SetOperation(cm.thop)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_DESTROYED)
        e2:SetRange(0x04)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        e2:SetCondition(cm.effcon2)
        e2:SetOperation(cm.thop)
        tc:RegisterEffect(e2)
        if tc:GetFlagEffect(m)==0 then
            tc:RegisterFlagEffect(m,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(m,0))
        end
    end
end

function cm.effcon1(e)
    return aux.bdocon(e) and e:GetHandler():GetFlagEffect(m+1)==0
end

function cm.effcon2(e)
    local c=e:GetHandler()
    local re=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_EFFECT)
    return re and re:GetHandler()==e:GetHandler() and c:GetFlagEffect(m+1)==0
end

function cm.optfilter(c)
    return c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsExistingMatchingCard(cm.optfilter,tp,0x11,0x10,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(m,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local g=Duel.SelectMatchingCard(tp,cm.optfilter,tp,0x11,0x10,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,tp,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
        e:GetHandler():RegisterFlagEffect(m+1,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(m,1))
    end
end

function cm.contfilter(c)
    return not c:IsCode(m)
end

function cm.tgcon(e)
	return Duel.IsExistingMatchingCard(cm.contfilter,e:GetHandlerPlayer(),0x04,0,1,nil)
end