-- 惊魂夜颂歌 环状水星
-- ID: 26052009
-- 字段：逆时残响 0x910 / 升阶 0x911
-- 8星同调调整怪兽
local s,id=GetID()
function s.initial_effect(c)
    -- 同调召唤：逆时残响调整 + 调整以外1只以上
    aux.AddSynchroProcedure(c, s.tunfilter, aux.NonTuner(nil), 1)
    c:EnableReviveLimit()

    -- 规则上也当作「升阶」「逆时残响」卡使用
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

    -- ① 同调召唤时，特召墓地·除外区1只8星以下本家同调怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- ② 从墓地除外自身，以自己场上1只本家怪兽为对象，宣言属性
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATTRIBUTE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCost(s.cost2)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
end

-- 同调素材：逆时残响调整
function s.tunfilter(c)
    return c:IsSetCard(0x910) and c:IsType(TYPE_TUNER)
end

-- ① 条件：同调召唤
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- ① 过滤：除调整外的8星以下本家同调怪兽
function s.spfilter1(c,e,tp)
    return c:IsSetCard(0x910) and c:IsType(TYPE_SYNCHRO) and c:IsLevelBelow(8)
        and not c:IsType(TYPE_TUNER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ① 目标：只检查条件
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

-- ① 操作：在操作中选择并特召
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ② cost：从墓地除外自身
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

-- ② 目标：自己场上1只「逆时残响」怪兽（取对象）
function s.tgfilter2(c)
    return c:IsFaceup() and c:IsSetCard(0x910) and c:IsType(TYPE_MONSTER)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter2(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tgfilter2,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.tgfilter2,tp,LOCATION_MZONE,0,1,1,nil)
    -- 宣言属性
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
    local att=Duel.AnnounceAttribute(tp,1,0x7f)
    e:SetLabel(att)
    Duel.SetOperationInfo(0,CATEGORY_ATTRIBUTE,g,1,0,0)
end

-- ② 操作：属性变更直到回合结束
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    local att=e:GetLabel()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if not att or att<=0 then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e1:SetValue(att)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e1)
end