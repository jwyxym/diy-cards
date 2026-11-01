-- 魅魇·薇瑟忒
local s,id,o=GetID()
local SET_MIYAN=0xfa3

function s.initial_effect(c)
    aux.AddXyzProcedure(c,nil,8,2,s.alterfilter,aux.Stringid(id,3),2,s.alterop)
    c:EnableReviveLimit()

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_RECOVER)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.ovtg)
    e1:SetOperation(s.ovop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_POSITION)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+o)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e2:SetCost(s.poscost)
    e2:SetTarget(s.postg)
    e2:SetOperation(s.posop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_CONTROL)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_LEAVE_FIELD)
    e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,id+o*2)
    e3:SetCondition(s.ctlcon)
    e3:SetTarget(s.ctltg)
    e3:SetOperation(s.ctlop)
    c:RegisterEffect(e3)
end

s.listed_series={SET_MIYAN}

function s.alterfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_MIYAN) and c:IsType(TYPE_XYZ) and c:GetRank()==4
end

function s.alterop(e,tp,chk)
    if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end

function s.ovfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end

function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ovfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.ovfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectTarget(tp,s.ovfilter,tp,0,LOCATION_MZONE,1,1,nil)
    local tc=g:GetFirst()
    local def=tc:GetBaseDefense()
    if def<0 then def=0 end
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,def)
end

function s.ovop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
        local def=tc:GetBaseDefense()
        if def<0 then def=0 end
        Duel.Overlay(c,Group.FromCards(tc))
        Duel.BreakEffect()
        Duel.Recover(tp,def,REASON_EFFECT)
    end
end

function s.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
    c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.posfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
        and not c:IsType(TYPE_LINK) and c:GetDefense()==0
end

function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.posfilter,tp,0,LOCATION_MZONE,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
    if #g==0 then return end
    Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)

    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_PIERCE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.ctlcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsPreviousPosition(POS_FACEUP)
        and c:GetReasonPlayer()==1-tp
end

function s.ctlfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end

function s.ctltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctlfilter(chkc) end
    if chk==0 then
        return Duel.IsExistingTarget(s.ctlfilter,tp,0,LOCATION_MZONE,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
    local g=Duel.SelectTarget(tp,s.ctlfilter,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

function s.ctlop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.GetControl(tc,tp)
    end
end