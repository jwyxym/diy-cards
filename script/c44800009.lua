-- 妖仙兽的赤城颪
-- ID: 44800009
-- 字段: 0xb3
-- 永续陷阱
local s,id=GetID()
function s.initial_effect(c)
    -- 发动（作为永续陷阱，盖放后下一回合才能发动）
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    -- ① 场上只能有1张表侧表示存在
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UNIQUE_ON_FIELD)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_SZONE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- ② 1回合1次，对方召唤·特召时，手卡特召4星以下妖仙兽，之后可选弹回自己场上1只妖仙兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.spcon)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)

    -- ③ 1回合最多2次，自己妖仙兽回手/卡组时，选对方1卡回手
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_TO_HAND)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(2,id+100)
    e4:SetCondition(s.retcon)
    e4:SetTarget(s.rettg)
    e4:SetOperation(s.retop)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EVENT_TO_DECK)
    c:RegisterEffect(e5)
end

-- ② 条件：对方召唤·特殊召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsControler, 1, nil, 1-tp)
end
-- ② 目标：手卡有可特召的4星以下妖仙兽
function s.spfilter(c,e,tp)
    return c:IsSetCard(0xb3) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ② 操作
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
        -- 询问是否弹回场上1只妖仙兽
        if Duel.IsExistingMatchingCard(s.retfilter,tp,LOCATION_MZONE,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
            local rg = Duel.SelectMatchingCard(tp,s.retfilter,tp,LOCATION_MZONE,0,1,1,nil)
            if #rg>0 then
                Duel.SendtoHand(rg,nil,REASON_EFFECT)
            end
        end
    end
end
function s.retfilter(c)
    return c:IsSetCard(0xb3) and c:IsAbleToHand()
end

-- ③ 条件：自己的妖仙兽卡回手/卡组
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.filter3, 1, nil, tp)
end
function s.filter3(c,tp)
    return c:IsSetCard(0xb3) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp)
        and (c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_DECK))
end
-- ③ 目标（不取对象）
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_ONFIELD)
end
-- ③ 操作：选对方场上1卡回手
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local g = Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local sg = g:Select(tp,1,1,nil)
        Duel.SendtoHand(sg,nil,REASON_EFFECT)
    end
end