-- 源计划 升华
-- ID: 26051945
-- 字段：0x904 / 0x905
local s,id=GetID()
function s.initial_effect(c)
    -- 规则上当作「源计划公司」卡使用
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0:SetValue(0x905)
    c:RegisterEffect(e0)

    -- ① 破坏场上「源计划」卡，从手卡特召，并机械族自肃
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- ② 选最多2只自己机械族怪兽，等级上升或下降2星（非取对象）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.lvtg2)
    e2:SetOperation(s.lvop2)
    c:RegisterEffect(e2)

    -- ③ 被战斗·效果破坏时，从卡组送墓1张自身以外的「源计划」卡
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetCountLimit(1,id+2000)
    e3:SetCondition(s.tgcon)
    e3:SetTarget(s.tgtg)
    e3:SetOperation(s.tgop)
    c:RegisterEffect(e3)
end

-- ① 目标与操作
function s.desfilter1(c)
    return c:IsSetCard(0x904) and c:IsFaceup()
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.desfilter1,tp,LOCATION_ONFIELD,0,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,s.desfilter1,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetTargetCard(g)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- 自肃
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
        if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        end
    end
end
function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_MACHINE)
end

-- ② 过滤：自己场上表侧机械族且有等级
function s.lvfilter(c)
    return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsLevelAbove(1)
end
-- ② 目标：只检查是否存在符合的怪兽
function s.lvtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ② 操作：直接选择怪兽，逐个处理升降
function s.lvop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g = Duel.SelectMatchingCard(tp, s.lvfilter, tp, LOCATION_MZONE, 0, 1, 2, nil)
    for tc in aux.Next(g) do
        local lv = tc:GetLevel()
        local opt = 0
        if lv > 1 then
            opt = Duel.SelectOption(tp, aux.Stringid(id,3), aux.Stringid(id,4))
        end
        local lvchg = 2
        if opt == 1 then lvchg = -2 end
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_LEVEL)
        e1:SetValue(lvchg)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end

-- ③ 条件与操作
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return bit.band(r, REASON_BATTLE+REASON_EFFECT) ~= 0
end
function s.tgfilter(c,code)
    return c:IsSetCard(0x904) and not c:IsCode(code) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler():GetCode()) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetHandler():GetCode())
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end