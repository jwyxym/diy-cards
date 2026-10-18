-- 速攻魔法
-- ID: 15040015
-- 字段：羽丘 (0xb13)
local s,id=GetID()
function s.initial_effect(c)
    -- 卡的发动（1回合只能发动1张）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- 目标：以自己场上1只怪兽为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsAbleToDeck() end
    if chk==0 then
        -- 检查场上是否有可返回卡组的怪兽，且卡组/手卡存在属性不同的「羽丘」怪兽
        local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_MZONE,0,nil)
        return #g>0 and g:IsExists(s.spcheck,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

-- 可返回卡组的怪兽过滤
function s.tdfilter(c)
    return c:IsAbleToDeck()
end

-- 检查是否存在属性不同的「羽丘」怪兽可特殊召唤
function s.spcheck(c,e,tp)
    local attr=c:GetAttribute()
    return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,attr)
end
-- 特殊召唤对象：「羽丘」怪兽且属性与返回的怪兽不同
function s.spfilter(c,e,tp,attr)
    return c:IsSetCard(0xb13) and c:IsAttribute(attr~=ATTRIBUTE_ALL and ~attr or 0)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- 操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc:IsRelateToEffect(e) then return end
    local attr=tc:GetAttribute()
    if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,attr)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end
-- 操作中用到的过滤（属性不同）
function s.spfilter2(c,e,tp,attr)
    return c:IsSetCard(0xb13) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and not c:IsAttribute(attr)
end