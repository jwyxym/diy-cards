local s,id=GetID()

function s.initial_effect(c)
    -- ① 发动时：回收念动力族
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.thtg1)
    e1:SetOperation(s.thop1)
    c:RegisterEffect(e1)

    -- ② 念动力族离场时：检索不同属性同等级，并丢手
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.thcon2)
    e2:SetTarget(s.thtg2)
    e2:SetOperation(s.thop2)
    c:RegisterEffect(e2)

    -- ③ 念动力族战斗时，对方不能发动卡的效果
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_ATTACK_ANNOUNCE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.btlcon)
    e3:SetOperation(s.btlop)
    c:RegisterEffect(e3)
end

-- ① 回收效果
function s.thfilter1(c)
    return c:IsRace(RACE_PSYCHIC) and c:IsAbleToHand()
end

function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.thop1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ② 离场检索效果
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and eg:IsExists(function(c) 
        return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsRace(RACE_PSYCHIC) and c:IsReason(REASON_EFFECT) 
    end, 1, nil)
end

function s.thfilter2(c,attr,lv)
    return c:IsRace(RACE_PSYCHIC) and not c:IsAttribute(attr) and c:GetLevel()==lv and c:IsAbleToHand()
end

function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local tc = eg:GetFirst()
        return Duel.IsExistingMatchingCard(s.thfilter2, tp, LOCATION_DECK, 0, 1, nil, tc:GetAttribute(), tc:GetLevel())
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop2(e,tp,eg,ep,ev,re,r,rp)
    local tc = eg:GetFirst()
    local attr = tc:GetAttribute()
    local lv = tc:GetLevel()
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp, s.thfilter2, tp, LOCATION_DECK, 0, 1, 1, nil, attr, lv)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        
        Duel.BreakEffect()
        Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)
    end
end

-- ③ 战斗限制效果
function s.btlcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetAttacker()
    local tc2=Duel.GetAttackTarget()
    return (tc:IsRace(RACE_PSYCHIC) and tc:IsControler(tp)) or (tc2 and tc2:IsRace(RACE_PSYCHIC) and tc2:IsControler(tp))
end

function s.btlop(e,tp,eg,ep,ev,re,r,rp)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetTargetRange(0,1)
    e1:SetValue(1)
    e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
    Duel.RegisterEffect(e1,tp)
end