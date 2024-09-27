--盾之勇者成名录 菲洛
local cm,m=GetID()

function cm.initial_effect(c)
    aux.AddCodeList(c,10700521)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WINDBEAST),2,2,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(cm.regcon)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,m)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCountLimit(1,m+1)
    e3:SetCondition(cm.hcon)
	e3:SetTarget(cm.htg)
	e3:SetOperation(cm.hop)
	c:RegisterEffect(e3)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_WIND)
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

function cm.tgtfilter(c,tc)
    return not tc:GetMaterial():IsContains(c) and c:IsRace(RACE_WINDBEAST) and c:IsAbleToDeck()
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return cm.tgtfilter(chkc,e:GetHandler()) and chkc:IsLocation(0x10) and chkc:IsControler(tp) end
    if chk==0 then return Duel.IsExistingTarget(cm.tgtfilter,tp,0x10,0,1,nil,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cm.tgtfilter,tp,0x10,0,1,1,nil,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,nil,nil)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,nil)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT) then
        if tc:IsLocation(0x40) then
            Duel.Draw(tp,1,REASON_EFFECT)
        elseif tc:IsLocation(0x02) then
            Duel.ConfirmCards(1-tp,tc)
        end
    end
end

function cm.hcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetReasonPlayer()==1-tp
end

function cm.tgh1filter(c,tc)
    return c:GetRace()==tc:GetRace() and c:GetAttribute()==tc:GetAttribute() and tc:IsAbleToHand()
end

function cm.tghfilter(c)
    return Duel.IsExistingMatchingCard(cm.tgh1filter,tp,0x01,0,1,nil,c) and c:IsFaceup()
end

function cm.htg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return cm.tghfilter(chkc) and chkc:IsLocation(0x04) end
    if chk==0 then return Duel.IsExistingTarget(cm.tghfilter,tp,0x04,0x04,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cm.tghfilter,tp,0x04,0x04,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function cm.hop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	    local g=Duel.SelectMatchingCard(tp,cm.tgh1filter,tp,0x01,0,1,1,nil,tc)
        if #g>0 then
           Duel.SendtoHand(g,nil,REASON_EFFECT)
           Duel.ConfirmCards(1-tp,g)
        end
    end
end