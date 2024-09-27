--请问您今天要来点兔子吗? 奈津惠
local cm,m=GetID()

function cm.initial_effect(c)
	aux.AddCodeList(c,10700036)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_PLANT),2,3,cm.lcheck)
    c:EnableReviveLimit()
    --splimit
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetOperation(cm.regop)
	c:RegisterEffect(e0)
    --spsummonsuccess
    local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(cm.regcon)
	e1:SetTarget(cm.tdtg)
	e1:SetOperation(cm.tdop)
	c:RegisterEffect(e1)
    --spsummonsuccess
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,m)
    e2:SetCondition(cm.thcon)
	e2:SetTarget(cm.thtg)
	e2:SetOperation(cm.thop)
	c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,m+1)
	e3:SetTarget(cm.hdtg)
	e3:SetOperation(cm.hdop)
	c:RegisterEffect(e3)
end

function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_FIRE)
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
	return c:IsCode(m)
end

function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=e:GetHandler():GetMutualLinkedGroup():Filter(Card.IsRace,nil,RACE_PLANT)
    if chk==0 then return #g>0 and Duel.IsPlayerCanDraw(tp,#g) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,#g)
end

function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetHandler():GetMutualLinkedGroup():Filter(Card.IsRace,nil,RACE_PLANT)
    if #g>0 then
        Duel.Draw(tp,#g,REASON_EFFECT)
    end
end

function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end

function cm.thtfilter(c,e,tp)
    return c:IsRace(RACE_PLANT) and c:IsLinkBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(0x10) and chkc:IsControler(tp) and cm.thtfilter(chkc,e,tp) end
    if chk==0 then return Duel.IsExistingTarget(cm.thtfilter,tp,0x10,0,1,nil,e,tp) and Duel.GetLocationCount(tp,0x04)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cm.thtfilter,tp,0x10,0,1,1,nil,e,tp)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,nil,nil)
end

function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
    end
end

function cm.tghfilter(c)
    return c:IsFaceup() and not c:IsCode(m)
end

function cm.hdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(0x04) and cm.tghfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cm.tghfilter,tp,0x04,0x04,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,cm.tghfilter,tp,0x04,0x04,1,1,nil)
end

function cm.hdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local c=e:GetHandler()
        local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(m,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_ADD_RACE)
		e1:SetValue(RACE_PLANT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_UPDATE_ATTACK)
        e2:SetRange(LOCATION_MZONE)
        e2:SetValue(400)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
    end
end