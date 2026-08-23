-- 魊影的沧腕 亚戈斯
-- ID: 26051966（请根据数据库实际ID修改）
-- 字段：魊影 (0x18a)
local s,id=GetID()
function s.initial_effect(c)
    -- 同调召唤：鱼族调整1只以上 + 调整以外怪兽1只以上
    aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FISH),aux.NonTuner(nil),1)
    c:EnableReviveLimit()

    -- ① 同调召唤时，对方场上·墓地最多3张卡除外
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)

    -- ② 攻守变化（自己上升，对方下降）
    local e2a=Effect.CreateEffect(c)
    e2a:SetType(EFFECT_TYPE_SINGLE)
    e2a:SetCode(EFFECT_UPDATE_ATTACK)
    e2a:SetRange(LOCATION_MZONE)
    e2a:SetValue(s.upval)
    c:RegisterEffect(e2a)
    local e2b=e2a:Clone()
    e2b:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2b)

    local e2c=Effect.CreateEffect(c)
    e2c:SetType(EFFECT_TYPE_FIELD)
    e2c:SetCode(EFFECT_UPDATE_ATTACK)
    e2c:SetRange(LOCATION_MZONE)
    e2c:SetTargetRange(0,LOCATION_MZONE)
    e2c:SetValue(s.downval)
    c:RegisterEffect(e2c)
    local e2d=e2c:Clone()
    e2d:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2d)

    -- ③ 双方回合，除外自身，从额外卡组特召「最远方的魊影」当作同调召唤
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1000)
    e3:SetCost(s.spcost3)
    e3:SetTarget(s.sptg3)
    e3:SetOperation(s.spop3)
    c:RegisterEffect(e3)
end

-- ① 条件：同调召唤
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- ① 目标：对方场上·墓地最多3张卡
function s.rmfilter(c)
    return c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- ① 操作：选择并除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g = Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg = g:Select(tp,1,3,nil)
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
    end
end

-- ② 自己除外区的表侧卡数量
function s.count_excluded(tp)
    return Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_REMOVED,0,nil)
end
-- 自己上升值
function s.upval(e,c)
    return s.count_excluded(e:GetHandlerPlayer()) * 100
end
-- 对方下降值（相同数值的负值）
function s.downval(e,c)
    return -s.count_excluded(e:GetHandlerPlayer()) * 100
end

-- ③ cost：除外自身
function s.spcost3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

-- ③ 目标：额外卡组的「最远方的魊影」
function s.spfilter3(c,e,tp)
    return c:IsCode(72309040) -- 最远方的魊影
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③ 操作：特召
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter3,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g:GetFirst(),SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
    end
end