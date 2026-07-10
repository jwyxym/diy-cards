--极神皇 托尔（动画）
--同调怪兽
--召唤条件：调整+调整以外的怪兽2只以上
--效果1：1回合1次，自己的主要阶段才能发动。选对方1只表侧表示怪兽的效果无效化。那之后，获得那只怪兽的效果。
--效果2：场上表侧表示存在的这张卡被破坏送去墓地的场合，结束阶段时可以从墓地在自己场上特殊召唤。这个效果特殊召唤成功时，给与对方基本分800分的伤害。这个效果特殊召唤的这个回合，这张卡不会被效果破坏。

local s,id=GetID()
function s.initial_effect(c)
    -- 同调召唤
    aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2)
    c:EnableReviveLimit()
    
    -- 效果1：无效并获取对方怪兽效果
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)
    
    -- 效果2：被破坏时在结束阶段特殊召唤
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_PHASE+PHASE_END)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1)
    e2:SetCondition(s.spcon)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
    
    -- 记录被破坏的标记
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetOperation(s.regop)
    c:RegisterEffect(e3)
end

-- 效果1相关函数
function s.filter1(c)
    return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter1(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,0,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    Duel.SelectTarget(tp,s.filter1,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsDisabled() then
        -- 无效目标怪兽的效果
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e2)
        
        -- 获得目标怪兽的效果
        local code=tc:GetOriginalCode()
        c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
    end
end

-- 记录被破坏并设置标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) then
        c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
    end
end

-- 效果2相关函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)>0
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
        if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
            -- 给与伤害
            Duel.Damage(1-tp,800,REASON_EFFECT)
            
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
end