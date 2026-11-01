-- 这次就由我 冰川纱夜
-- ID: 44821009
-- 记述「Roselia」(44821000)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,44821000)

    -- 融合素材：「双胞胎的烦恼 冰川纱夜」+ 植物族·暗属性怪兽
    c:EnableReviveLimit()
    aux.AddFusionProcFun2(c,
        aux.FilterBoolFunction(Card.IsCode,44821003),
        function(fc) return fc:IsRace(RACE_PLANT) and fc:IsAttribute(ATTRIBUTE_DARK) and fc:IsType(TYPE_MONSTER) end,
        true)

    -- ① 不会被战斗破坏
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- ② 主要阶段，以对方场上1只怪兽为对象破坏，1回合可使用最多自己场上记述「Roselia」融合怪兽数量的次数
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id)  -- 防止同一时点无限连锁，实际次数由条件控制
    e2:SetCondition(s.descon)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)

    -- ③ 双方回合，自己场上有3只以上记述「Roselia」的怪兽时，以对方场上1张表侧卡为对象无效其效果直到回合结束
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DISABLE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.discon)
    e3:SetTarget(s.distg)
    e3:SetOperation(s.disop)
    c:RegisterEffect(e3)
end

-- ② 场上记述「Roselia」的融合怪兽过滤
function s.rosefilter(c)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and aux.IsCodeListed(c,44821000)
end

-- ② 条件：本回合已发动次数 < 自己场上符合条件的融合怪兽数量
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    local cnt=Duel.GetMatchingGroupCount(s.rosefilter,tp,LOCATION_MZONE,0,nil)
    return cnt>0 and Duel.GetFlagEffect(tp,id) < cnt
end

-- ② 目标：对方场上1只怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsDestructable() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsDestructable,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,Card.IsDestructable,tp,0,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

-- ② 操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
    -- 记录本回合发动次数，重置到回合结束
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end

-- ③ 条件：自己场上有3只以上记述「Roselia」的表侧怪兽
function s.discon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetMatchingGroupCount(function(c) return c:IsFaceup() and aux.IsCodeListed(c,44821000) end,tp,LOCATION_MZONE,0,nil)>=3
end

-- ③ 目标：对方场上1张表侧卡
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

-- ③ 操作：效果无效直到回合结束
function s.disop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetValue(RESET_TURN_SET)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e2)
    end
end