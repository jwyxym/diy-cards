-- 源计划 瞬影围捕
-- ID: 26051950
-- 字段: 0x904
local s,id=GetID()
function s.initial_effect(c)
    -- ① 除外场上1卡，有「源计划 阴」再除外1张
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.rmcon1)
    e1:SetTarget(s.rmtg1)
    e1:SetOperation(s.rmop1)
    c:RegisterEffect(e1)

    -- ② 攻击宣言时墓地除外，对方怪兽攻击力下降1000
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_ATTACK_ANNOUNCE)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.atkcon2)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.atktg2)
    e2:SetOperation(s.atkop2)
    c:RegisterEffect(e2)
end

-- 自定义过滤：表侧「源计划」怪兽（替代 aux.FilterFaceup）
function s.faceupfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x904)
end

-- ① 条件：自己场上有表侧「源计划」怪兽
function s.rmcon1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.faceupfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ① 目标
function s.rmtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ① 操作
function s.rmop1(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)==0 then return end
    end
    -- 自己场上有「源计划 阴」存在的场合，再选场上1张卡除外
    if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,26051948) then
        local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
            local sg=dg:Select(tp,1,1,nil)
            Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
        end
    end
end

-- ② 条件：自己的「源计划」怪兽和对方怪兽进行战斗的攻击宣言
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
    local at=Duel.GetAttacker()
    return at:IsControler(tp) and at:IsSetCard(0x904)
end
-- ② 目标：无
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- ② 操作
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(-1000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end