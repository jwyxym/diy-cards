--幻念引梦士
local cm,m,o=GetID()
function cm.initial_effect(c)
    c:EnableReviveLimit()
    --material
    aux.AddFusionProcFun2(c,cm.matfilter1,cm.matfilter2,true)
    --fusion material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(cm.val)
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_LEAVE_FIELD)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,m)
    e1:SetCondition(cm.thcon)
    e1:SetTarget(cm.thtg)
    e1:SetOperation(cm.thop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DRAW+CATEGORY_RECOVER+CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,m+1)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e2:SetTarget(cm.tg)
    e2:SetOperation(cm.op)
    c:RegisterEffect(e2)
end
cm.toss_dice=true
function cm.matfilter1(c)
    return c:IsSummonLocation(LOCATION_EXTRA) and c:IsLocation(LOCATION_MZONE)
end
function cm.val(e,se,sp,st)
	return st==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_MASK_CHANGE or se:GetHandler():IsCode(11100136)
end
function cm.matfilter2(c)
    return (c:IsSummonLocation(LOCATION_HAND) or c:IsSummonLocation(LOCATION_GRAVE)) and c:IsLocation(LOCATION_MZONE)
end
function cm.thcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp
end
function cm.thfilter(c)
    return c:IsAbleToHand() and c.toss_dice
end
function cm.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(cm.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function cm.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,cm.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if g:GetCount()>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
    local dc=Duel.TossDice(tp,1)
    if dc==1 then
        local e0=Effect.CreateEffect(e:GetHandler())
        e0:SetType(EFFECT_TYPE_FIELD)
        e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e0:SetCode(EFFECT_CANNOT_ACTIVATE)
        e0:SetTargetRange(1,0)
        e0:SetValue(cm.d_aclimit)
        e0:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e0,tp)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_DELAY)
        e1:SetCode(EVENT_SPSUMMON_SUCCESS)
        e1:SetCondition(cm.d_con)
        e1:SetOperation(cm.d_op)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    elseif dc==2 or dc==3 then
        Duel.Damage(tp,1000,REASON_EFFECT)
        Duel.Draw(tp,1,REASON_EFFECT)
    elseif dc==4 or dc==5 then
        Duel.Recover(tp,1000,REASON_EFFECT)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
        if g:GetCount()>0 then
            Duel.HintSelection(g)
            Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        end
    else
        local e0=Effect.CreateEffect(e:GetHandler())
        e0:SetType(EFFECT_TYPE_FIELD)
        e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e0:SetCode(EFFECT_CANNOT_ACTIVATE)
        e0:SetTargetRange(1,0)
        e0:SetValue(cm.r_aclimit)
        e0:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e0,tp)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
        e1:SetProperty(EFFECT_FLAG_DELAY)
        e1:SetCode(EVENT_SPSUMMON_SUCCESS)
        e1:SetCondition(cm.r_con)
        e1:SetOperation(cm.r_op)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
    end
end
function cm.d_aclimit(e,re,tp)
    return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSummonLocation(LOCATION_EXTRA) and re:GetHandler():IsLocation(LOCATION_MZONE)
end
function cm.r_aclimit(e,re,tp)
    return re:IsActiveType(TYPE_MONSTER) and (re:GetHandler():IsSummonLocation(LOCATION_HAND) or re:GetHandler():IsSummonLocation(LOCATION_GRAVE)) and re:GetHandler():IsLocation(LOCATION_MZONE)
end
function cm.d_filter(c,sp)
    return c:IsSummonPlayer(sp) and (c:IsSummonLocation(LOCATION_HAND) or c:IsSummonLocation(LOCATION_GRAVE))
end
function cm.d_con(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(cm.d_filter,1,nil,1-tp)
end
function cm.d_op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(tp,800,REASON_EFFECT)
    for tc in aux.Next(eg:Filter(cm.d_filter,nil,1-tp)) do
        if tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
            Duel.NegateRelatedChain(tc,RESET_TURN_SET)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetValue(RESET_TURN_SET)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e2)
        end
    end
end
function cm.r_filter(c,sp)
    return c:IsSummonPlayer(sp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function cm.r_con(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(cm.r_filter,1,nil,1-tp)
end
function cm.r_op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Recover(tp,800,REASON_EFFECT)
    for tc in aux.Next(eg:Filter(cm.r_filter,nil,1-tp)) do
        if tc:IsFaceup() then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
            e1:SetValue(1)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(e1)
        end
    end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    e:GetHandler():RegisterEffect(e1)
end