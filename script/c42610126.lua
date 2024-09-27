--转生成为了只有乙女游戏破灭Flag的邪恶大小姐 索菲亚·亚斯卡尔特
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
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,m)
	e1:SetTarget(cm.tdtg)
	e1:SetOperation(cm.tdop)
	c:RegisterEffect(e1)
    --indes
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BE_MATERIAL)
	e5:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e5:SetCondition(cm.indcon)
	e5:SetOperation(cm.indop)
	c:RegisterEffect(e5)
end

function cm.lckfilter(c)
    return c:IsLinkRace(RACE_SPELLCASTER) or c:IsLinkAttribute(ATTRIBUTE_WIND)
end

function cm.lcheck(g,lc)
	return g:IsExists(cm.lckfilter,1,nil)
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

function cm.tdtfilter(c)
    return c:IsLink(2) and c:IsAbleToDeck() and not c:IsCode(m)
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(0x10) and cm.tdtfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.tdtfilter,tp,0x10,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cm.tdtfilter,tp,0x10,0,1,1,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,nil,nil)
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
        local g=Group.FromCards(c,tc)
        if Duel.SendtoDeck(g,nil,2,REASON_EFFECT) then
            Duel.Recover(tp,1000,REASON_EFFECT)
        end
    end
end

function cm.indcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetHandler():GetReasonCard():GetMaterial():IsExists(Card.IsCode,1,nil,42610120)
end

function cm.indop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerCanDraw(tp,1) then
		Duel.Hint(HINT_CARD,0,m)
    	Duel.Draw(tp,1,REASON_EFFECT)
	end
end