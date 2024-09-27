--NEWGAME! 泷本日富美
local cm,m=GetID()

function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,2,cm.lcheck)
	c:EnableReviveLimit()
    --splimit
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(cm.regcon)
	e1:SetOperation(cm.regop)
	c:RegisterEffect(e1)
    --todeck
    local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(m,0))
    e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_REMOVE)
    e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,m)
    e4:SetCondition(cm.thcon)
	e4:SetTarget(cm.thtg)
	e4:SetOperation(cm.thop)
	c:RegisterEffect(e4)
    --todeck
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetRange(LOCATION_GRAVE)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,m+1)
	e5:SetTarget(cm.tdtg)
	e5:SetOperation(cm.tdop)
	c:RegisterEffect(e5)
end

function cm.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
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

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsFacedown,1,nil)
end

function cm.tgtdfilter(c)
    return c:IsFacedown() and c:IsAbleToDeck()
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(cm.tgtdfilter,1,nil) end
    local g=eg:Filter(cm.tgtdfilter,nil)
    Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,nil,nil,nil)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if #tg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=tg:Select(tp,1,math.min(#tg,3),nil)
        Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
    end
end

function cm.tgtfilter(c)
    return c:IsAbleToDeck() and c:IsFacedown()
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingTarget(cm.tgtfilter,tp,0x20,0x20,3,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cm.tgtfilter,tp,0x20,0x20,3,3,nil)
    g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,nil,nil)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if c:IsRelateToEffect(e) and #tg>0 then
		tg:AddCard(c)
        Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)
    end
end