local s,id=GetID()
local TWILIGHT=0x747
local HOLY=0x474

-- 全局监控：记录本回合是否发动过非光暗属性的怪兽效果
if not _G.TWILIGHT_ATTR_REG then
    _G.TWILIGHT_ATTR_REG = true
    local ge=Effect.GlobalEffect()
    ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge:SetCode(EVENT_CHAINING)
    ge:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        if re and re:IsActiveType(TYPE_MONSTER) then
            local rc = re:GetHandler()
            local attr = rc:GetAttribute()
            -- 如果有属性且不是光属性且不是暗属性，则设置标记
            if attr ~= 0 and (attr & ATTRIBUTE_LIGHT) == 0 and (attr & ATTRIBUTE_DARK) == 0 then
                Duel.RegisterFlagEffect(tp, id, RESET_PHASE+PHASE_END, 0, 1)
            end
        end
    end)
    Duel.RegisterEffect(ge, 0)
end

function s.no_other_attr(tp)
    local g1 = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    local g2 = Duel.GetMatchingGroup(nil, tp, LOCATION_GRAVE, 0, nil)
    local g = g1:Clone()
    g:Merge(g2)
    for tc in aux.Next(g) do
        if tc:IsType(TYPE_MONSTER) and not (tc:IsAttribute(ATTRIBUTE_LIGHT) or tc:IsAttribute(ATTRIBUTE_DARK)) then
            return false
        end
    end
    return true
end

function s.actcon(e)
    return s.no_other_attr(e:GetHandlerPlayer())
end

-- 发动非光暗怪兽效果的封锁过滤
function s.aclimit(e,re,tp)
    if not re:IsActiveType(TYPE_MONSTER) then return false end
    local rc = re:GetHandler()
    local attr = rc:GetAttribute()
    return attr ~= 0 and (attr & ATTRIBUTE_LIGHT) == 0 and (attr & ATTRIBUTE_DARK) == 0
end

function s.initial_effect(c)
    local ea=Effect.CreateEffect(c)
    ea:SetType(EFFECT_TYPE_SINGLE)
    ea:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    ea:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    ea:SetRange(LOCATION_SZONE)
    ea:SetCondition(s.actcon)
    c:RegisterEffect(ea)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon) -- 增加发动前置条件检查
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e2:SetCountLimit(2,id+100)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(2,id+100)
    e3:SetCondition(s.con3)
    e3:SetTarget(s.tg3)
    e3:SetOperation(s.op3)
    c:RegisterEffect(e3)
end

-- 发动前的全回合限制检查
function s.spcon(e,tp)
    return Duel.GetFlagEffect(tp, id) == 0
end

function s.thfilter(c)
    return c:IsSetCard(TWILIGHT)
end

function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
    -- 发动成功后，立刻赋予全回合只能发动光暗效果的自肃
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetValue(s.aclimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
    local sg=g:Select(tp,1,1,nil)
    local tc=sg:GetFirst()

    if tc:IsType(TYPE_MONSTER) then
        local b1=tc:IsAbleToHand()
        local b2=tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        if b1 and b2 then
            if Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,5))==0 then
                Duel.SendtoHand(tc,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,tc)
            else
                Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
            end
        elseif b1 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        elseif b2 then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
        end
    else
        local b1=tc:IsAbleToHand()
        local b2=tc:IsType(TYPE_SPELL+TYPE_TRAP) and tc:IsSSetable()
        if b1 and b2 then
            if Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0 then
                Duel.SendtoHand(tc,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,tc)
            else
                Duel.SSet(tp,tc)
            end
        elseif b1 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        elseif b2 then
            Duel.SSet(tp,tc)
        end
    end
end

function s.filter2(c)
    return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) and not c:IsType(TYPE_LINK)
end

function s.extra_filter(c)
    return (c:IsSetCard(HOLY) and c:IsType(TYPE_SYNCHRO)) or (c:IsSetCard(TWILIGHT) and c:IsType(TYPE_XYZ))
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter2(chkc) end
    if chk==0 then
        local has_target = Duel.IsExistingTarget(s.filter2,tp,LOCATION_MZONE,0,1,nil)
        local has_extra = Duel.IsExistingMatchingCard(s.extra_filter,tp,LOCATION_EXTRA,0,1,nil)
        return has_target and has_extra
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.filter2,tp,LOCATION_MZONE,0,1,1,nil)
end

function s.extra_spfilter(c,e,tp,attr,val)
    if not c:IsAttribute(attr) then return false end
    if c:IsSetCard(HOLY) and c:IsType(TYPE_SYNCHRO) and c:GetLevel()==val then return true end
    if c:IsSetCard(TWILIGHT) and c:IsType(TYPE_XYZ) and c:GetRank()==val then return true end
    return false
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local attr = tc:GetAttribute()
    local target_attr = 0
    if attr & ATTRIBUTE_LIGHT ~= 0 then target_attr = ATTRIBUTE_DARK
    elseif attr & ATTRIBUTE_DARK ~= 0 then target_attr = ATTRIBUTE_LIGHT
    else return end
    
    local lv = tc:GetLevel()
    local rk = tc:GetRank()
    local val = lv > 0 and lv or rk
    if val <= 0 then return end

    local g = Duel.GetMatchingGroup(s.extra_spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,target_attr,val)
    if g:GetCount()==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg = g:Select(tp,1,1,nil)
    local sc = sg:GetFirst()
    local sumtype = 0
    if sc:IsType(TYPE_SYNCHRO) then
        sumtype = SUMMON_TYPE_SYNCHRO
    elseif sc:IsType(TYPE_XYZ) then
        sumtype = SUMMON_TYPE_XYZ
    end
    if sumtype == 0 then return end
    if Duel.SpecialSummon(sc, sumtype, tp, tp, false, false, POS_FACEUP) ~= 0 then
        if tc:IsLocation(LOCATION_MZONE) then
            Duel.SendtoDeck(tc, nil, SEQ_DECKTOP, REASON_EFFECT)
        end
    end
end

function s.con3(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and re and re:IsActiveType(TYPE_MONSTER)
end

function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_GRAVE) then
        Duel.MoveToField(c, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
    end
end