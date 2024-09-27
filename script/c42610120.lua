--转生成为了只有乙女游戏破灭Flag的邪恶大小姐 卡塔莉娜·克拉艾斯
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
    --spsummonsuccess
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(cm.regcon)
	e1:SetTarget(cm.tdtg)
	e1:SetOperation(cm.tdop)
	c:RegisterEffect(e1)
    --link2
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,m)
    e2:SetCost(cm.spcon)
	e2:SetTarget(cm.sptg)
	e2:SetOperation(cm.spop)
	c:RegisterEffect(e2)
end

function cm.lckfilter(c)
    return c:IsLinkRace(RACE_SPELLCASTER) or c:IsLinkAttribute(ATTRIBUTE_EARTH)
end

function cm.lcheck(g,lc)
	return g:IsExists(cm.lckfilter,1,nil) and not g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
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

function cm.tdtfilter(c,e)
    return c:IsLink(2) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end

function cm.tdtsfilter(g)
    return #g==g:GetClassCount(Card.GetCode)
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(0x10) and cm.tdtfilter(chkc) end
	if chk==0 then return Duel.IsExistingMatchingCard(cm.tdtfilter,tp,0x10,0x10,1,nil,e) end
    local gg=Duel.GetMatchingGroup(cm.tdtfilter,tp,0x10,0x10,nil,e)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=gg:SelectSubGroup(tp,cm.tdtsfilter,false,1,gg:GetClassCount(Card.GetCode))
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,nil,nil)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)
end

function cm.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end

function cm.lspfilter(c,tp,mg)
    return c:IsLinkSummonable(mg,nil,2,2) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end

function cm.sptfilter(c,tp,tc)
    return c:IsLink(2) and Duel.IsExistingMatchingCard(cm.lspfilter,tp,LOCATION_EXTRA,0,1,nil,tp,Group.FromCards(c,tc))
end

function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
    if chkc then return chkc:IsLocation(0x04) and cm.sptfilter(chkc,tp,c)  end
	if chk==0 then return Duel.IsExistingTarget(cm.sptfilter,tp,0x04,0x04,1,c,tp,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,cm.sptfilter,tp,0x04,0x04,1,1,c,tp,c)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function cm.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)) then return false end
    local mg=Group.FromCards(c,tc)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cm.lspfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp,mg)
    if g:GetCount()>0 then
		Duel.LinkSummon(tp,g:GetFirst(),mg,nil,2,2)
	end
end