-- 妖仙之山 妖仙岚
-- ID: 44800007
-- 字段：妖仙兽 (0xb3)
local s,id=GetID()
function s.initial_effect(c)
    -- 规则上当作「妖仙兽」卡使用
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetRange(LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_ONFIELD)
    e0:SetValue(0xb3)
    c:RegisterEffect(e0)

    -- ① 发动时的效果处理：放置「修验的妖社」并可选特召「妖仙兽 木魅」
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.acttg)
    e1:SetOperation(s.actop)
    c:RegisterEffect(e1)

    -- ② 妖仙兽怪兽召唤·灵摆召唤时返回那些怪兽并检索
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.con2)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(s.con2_sp)
    c:RegisterEffect(e3)
end

-- ① 目标（空）
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

-- ① 操作
function s.actop(e,tp,eg,ep,ev,re,r,rp)
    -- 放置「修验的妖社」(27918963)
    if Duel.IsExistingMatchingCard(s.placefilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) then
        if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
            local g=Duel.SelectMatchingCard(tp,s.placefilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
            local tc=g:GetFirst()
            if tc then
                Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
            end
        end
    end

    -- 特召「妖仙兽 木魅」(23740893)
    if Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) then
        if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
            local tc=g:GetFirst()
            if tc then
                Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
            end
        end
    end
end

function s.placefilter(c)
    return c:IsCode(27918963) and not c:IsForbidden()
end

-- 修正：添加 e,tp 参数
function s.spfilter(c,e,tp)
    return c:IsCode(23740893) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ② 通常召唤条件
function s.filter2(c)
    return c:IsSetCard(0xb3) and c:IsFaceup()
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.filter2,1,nil)
end

-- ② 灵摆召唤条件
function s.con2_sp(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) return c:IsSetCard(0xb3) and c:IsSummonType(SUMMON_TYPE_PENDULUM) end,1,nil)
end

-- ② 目标
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local sg=eg:Filter(s.filter2,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,#sg,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ② 操作
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local sg=eg:Filter(s.filter2,nil)
    if #sg>0 and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local rg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #rg>0 then
            Duel.SendtoHand(rg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,rg)
        end
    end
end

function s.thfilter(c)
    return c:IsSetCard(0xb3) and c:IsAbleToHand()
end