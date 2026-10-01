-- 白沙和风 马库斯
-- ID: 26052003
-- 字段：逆时残响 0x910 / 升阶 0x911
local s,id=GetID()
function s.initial_effect(c)
    aux.AddSynchroProcedure(c, s.tunfilter, aux.NonTuner(nil), 1)
    c:EnableReviveLimit()

    -- 规则上也当作「升阶」「逆时残响」
    local e0b=Effect.CreateEffect(c)
    e0b:SetType(EFFECT_TYPE_SINGLE)
    e0b:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0b:SetCode(EFFECT_ADD_SETCODE)
    e0b:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0b:SetValue(0x911)
    c:RegisterEffect(e0b)
    local e0c=Effect.CreateEffect(c)
    e0c:SetType(EFFECT_TYPE_SINGLE)
    e0c:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0c:SetCode(EFFECT_ADD_SETCODE)
    e0c:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED)
    e0c:SetValue(0x910)
    c:RegisterEffect(e0c)

    -- ① 同调召唤时，墓地最多3张回卡组，抽1
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.tdcon)
    e1:SetTarget(s.tdtg)
    e1:SetOperation(s.tdop)
    c:RegisterEffect(e1)

    -- ② 双方回合，除外对方墓地1张卡，无效同名卡效果
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.rmtg2)
    e2:SetOperation(s.rmop2)
    c:RegisterEffect(e2)

    -- ③ 被送去墓地时，特召墓地其他本家
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetCountLimit(1,id+2000)
    e3:SetTarget(s.sptg3)
    e3:SetOperation(s.spop3)
    c:RegisterEffect(e3)
end

function s.tunfilter(c)
    return c:IsSetCard(0x910) and c:IsType(TYPE_TUNER)
end

-- ①
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,0,1,3,nil)
    if #g>0 then
        Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        Duel.Draw(tp,1,REASON_EFFECT)
    end
end

-- ② 除外对方墓地1张卡，无效同名卡效果
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_GRAVE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_GRAVE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        local code=tc:GetCode()
        if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
            e1:SetTarget(function(e,c) return c:IsCode(code) end)
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_FIELD)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
            e2:SetTarget(function(e,c) return c:IsCode(code) end)
            e2:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e2,tp)
        end
    end
end

-- ③ 被送墓时特召
function s.spfilter3(c,e,tp)
    return c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER) and not c:IsCode(id)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter3,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end