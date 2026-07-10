--极神皇 洛基（动画）
--同调怪兽
--召唤条件：调整+调整以外的怪兽2只以上
--效果1：这张卡进行攻击时（包括伤害步骤阶段），对方发动魔法·陷阱卡时才能发动。那个效果无效并破坏。
--效果2：场上表侧表示存在的这张卡被破坏送去墓地的场合，结束阶段时从墓地在自己场上特殊召唤。这个效果特殊召唤成功时，选择自己墓地存在的1张陷阱卡加入手卡。这个效果特殊召唤的这个回合，这张卡不会被效果破坏。

local s,id=GetID()
function s.initial_effect(c)
    -- 同调召唤
    aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2)
    c:EnableReviveLimit()
    
    -- 效果①：攻击时（含伤害步骤），对方发动魔陷时无效并破坏
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.negcon)
    e1:SetTarget(s.negtg)
    e1:SetOperation(s.negop)
    c:RegisterEffect(e1)
    
    -- 效果②：被破坏送墓时，结束阶段自动特殊召唤并回收陷阱
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e2:SetOperation(s.regop)
    c:RegisterEffect(e2)
end

-- 效果①：条件 - 攻击时（含伤害步骤），对方发动魔法陷阱
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    -- 检查这张卡是否在战斗
    local c=e:GetHandler()
    if not (c==Duel.GetAttacker() or c==Duel.GetAttackTarget()) then return false end
    -- 对方发动的必须是魔法陷阱卡
    return rp==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end

-- 效果①：目标 - 直接无效那个发动
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

-- 效果①：无效那个发动并破坏
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end

-- 效果②：被破坏时注册结束阶段效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsPreviousLocation(LOCATION_MZONE) or not c:IsPreviousPosition(POS_FACEUP) then return end
    
    -- 注册结束阶段自动处理效果
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetCountLimit(1)
    e1:SetOperation(s.endop)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetLabelObject(c)
    Duel.RegisterEffect(e1,tp)
end

-- 结束阶段处理（不入连锁）
function s.endop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetLabelObject()
    
    -- 特殊召唤自身
    if c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
        Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
        
        -- 回收墓地陷阱卡
        local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_GRAVE,0,nil,TYPE_TRAP)
        if #g>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local sg=g:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
            end
        end
        
        Duel.SpecialSummonComplete()
        
        -- ★★★ 新增：这个回合，这张卡不会被效果破坏 ★★★
        local e3=Effect.CreateEffect(c)
        e3:SetType(EFFECT_TYPE_SINGLE)
        e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
        e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        e3:SetRange(LOCATION_MZONE)
        e3:SetValue(1)
        e3:SetReset(RESET_PHASE+PHASE_END)
        c:RegisterEffect(e3)
    end
end