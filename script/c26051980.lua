-- 僵尸少女 布若
-- ID: 26051980
-- 字段：跃音萌行 0x906 / 凛 0x907 / 布若 0x908 / 玛莉嘉 0x909
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.linkcon)
    e0:SetOperation(s.linkop)
    e0:SetValue(SUMMON_TYPE_LINK)
    c:RegisterEffect(e0)

    local e0b=Effect.CreateEffect(c)
    e0b:SetType(EFFECT_TYPE_SINGLE)
    e0b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0b:SetCode(EFFECT_ADD_SETCODE)
    e0b:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0b:SetValue(0x906)
    c:RegisterEffect(e0b)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost1)
    e1:SetTarget(s.distg)
    e1:SetOperation(s.disop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,id+1000)
    e2:SetCost(s.cost2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
end

function s.total_link(mg)
    local total = 0
    local tc = mg:GetFirst()
    while tc do
        total = total + (tc:GetLink()>0 and tc:GetLink() or 1)
        tc = mg:GetNext()
    end
    return total
end
function s.has_setcode(mg, code)
    local tc = mg:GetFirst()
    while tc do
        if tc:IsSetCard(code) then return true end
        tc = mg:GetNext()
    end
    return false
end

function s.linkcon(e,c,og,lmat,min,max)
    if c==nil then return true end
    local tp=c:GetControler()
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    if #g < 2 then return false end
    if not s.has_setcode(g, 0x908) then return false end
    return s.total_link(g) >= 4
end
function s.linkop(e,tp,eg,ep,ev,re,r,rp,c,og,lmat,min,max)
    if c==nil then return end
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, 0, nil)
    if not s.has_setcode(g, 0x908) then return end

    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_XMATERIAL)
    local sg = g:Select(tp, 2, #g, nil)
    if #sg < 2 then return end
    if not s.has_setcode(sg, 0x908) then return end
    if s.total_link(sg) ~= 4 then return end

    c:SetMaterial(sg)
    Duel.SendtoGrave(sg, REASON_MATERIAL+REASON_LINK)
end

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
    Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.disfilter(c)
    return c:IsFaceup()
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and s.disfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.disfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsFaceup() and tc:IsRelateToEffect(e) then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e2)
    end
end

function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function s.spfilter2(c,e,tp)
    return (c:IsSetCard(0x907) or c:IsSetCard(0x909))
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local g1 = Duel.GetMatchingGroup(s.spfilter2, tp, LOCATION_GRAVE, 0, nil, e, tp)
    if #g1 > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg1 = g1:Filter(Card.IsSetCard, nil, 0x907):Select(tp, 0, 1, nil)
        if #sg1 > 0 then
            Duel.SpecialSummon(sg1, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
    local g2 = Duel.GetMatchingGroup(s.spfilter2, tp, LOCATION_GRAVE, 0, nil, e, tp)
    if #g2 > 0 then
        Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
        local sg2 = g2:Filter(Card.IsSetCard, nil, 0x909):Select(tp, 0, 1, nil)
        if #sg2 > 0 then
            Duel.SpecialSummon(sg2, 0, tp, tp, false, false, POS_FACEUP)
        end
    end
end