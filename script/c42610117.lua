--赤色誓约 阿黛尔·冯·阿斯卡姆
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
    --atk
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SET_BASE_ATTACK)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetValue(cm.adval)
	c:RegisterEffect(e6)
    --spsummonsuccess
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,m)
    e1:SetCondition(cm.drcon)
	e1:SetTarget(cm.drtg)
	e1:SetOperation(cm.drop)
	c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(cm.thtg)
	e3:SetOperation(cm.thop)
	c:RegisterEffect(e3)
    if not cm.global_check then
        cm.global_check=true
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
        e1:SetCode(EVENT_ADJUST)
        e1:SetOperation(cm.adopsp)
        Duel.RegisterEffect(e1,0)
        local e2=e1:Clone()
        e2:SetCode(EVENT_SPSUMMON_SUCCESS)
        Duel.RegisterEffect(e2,0)
    end
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_DIVINE) or g:IsExists(Card.IsLinkRace,1,nil,RACE_SPELLCASTER)
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

function cm.spafilter(c)
    return c:IsFaceup() and c:GetAttack()>0 and not c:IsCode(m)
end

function cm.adopsp(e)
    if Duel.GetFlagEffect(0,m)==0 then
        Duel.RegisterFlagEffect(0,m,0,0,1,0)
    end
    local g=Duel.GetMatchingGroup(cm.spafilter,0,0x04,0x04,nil)
    if #g>0 then
        for tc in aux.Next(g) do
            local atk=tc:GetAttack()
            if atk>Duel.GetFlagEffectLabel(0,m) then
                Duel.SetFlagEffectLabel(0,m,atk)
            end
        end
    end
end

function cm.adval(e,c)
	return Duel.GetFlagEffectLabel(0,m)//2
end

function cm.drcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DIVINE)
end

function cm.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function cm.drop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Draw(tp,1,REASON_EFFECT) then
        local c=e:GetHandler()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetRange(LOCATION_MZONE)
        e1:SetValue(2000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        c:RegisterEffect(e1)
    end
end

function cm.thtfilter(c)
    return c:IsAbleToHand() and c:IsAttribute(ATTRIBUTE_DIVINE)
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(0x10) and cm.thtfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.thtfilter,tp,0x10,0x10,1,nil) and c:IsAbleToHand() end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,cm.thtfilter,tp,0x10,0x10,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,nil,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,nil,nil)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToChain() and Duel.SendtoDeck(c,nil,2,REASON_EFFECT) then
        local tc=Duel.GetFirstTarget()
        if tc:IsRelateToChain() then
            Duel.SendtoHand(tc,tp,REASON_EFFECT)
            if tc:IsLocation(0x02) then
                Duel.ConfirmCards(1-tp,tc)
            end
        end
    end
end