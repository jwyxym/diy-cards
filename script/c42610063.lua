--NEWGAME! 凉风青叶
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
    --draw
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    e4:SetCondition(cm.thcon)
    e4:SetCost(cm.thcost)
	e4:SetTarget(cm.thtg)
	e4:SetOperation(cm.thop)
	c:RegisterEffect(e4)
    --todeck
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_TODECK)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_GRAVE)
    e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,m)
	e5:SetTarget(cm.tdtg)
	e5:SetOperation(cm.tdop)
	c:RegisterEffect(e5)
end

function cm.lcheck(g)
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

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function cm.costtfilter(c)
    return c:IsAbleToRemoveAsCost() and c:IsType(0x1)
end

function cm.costgfilter(g)
	return g:GetClassCount(Card.GetLocation)==#g
end

function cm.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local rg=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,0x02,0,c:GetMaterial())
	local hg=Duel.GetMatchingGroup(cm.costtfilter,tp,0x10,0,c:GetMaterial())
	if chk==0 then return #rg>0 and #hg>0 end
	local g=rg:__add(hg)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	g=g:SelectSubGroup(tp,cm.costgfilter,false,2,2)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end

function cm.tgtfilter(c)
    return c:IsAbleToDeck() and c:IsFaceup()
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
	if chk==0 then return e:GetHandler():IsAbleToDeck() and Duel.IsExistingTarget(cm.tgtfilter,tp,0x20,0x20,2,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cm.tgtfilter,tp,0x20,0x20,2,2,nil)
    g:AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,nil,nil)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if c:IsRelateToEffect(e) and #tg>0 then
		tg:AddCard(c)
        Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)
    end
end