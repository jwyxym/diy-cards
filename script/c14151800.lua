-- 神之束缚 德洛弥（动画）
local s,id=GetID()
function s.initial_effect(c)
    --发动效果
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

--条件过滤：自己场上的极神怪兽或幻神兽族
function s.filter1(c)
    return c:IsFaceup() and (c:IsSetCard(0x4b) or c:IsRace(RACE_DIVINE))
end

--条件过滤：对方场上的表侧怪兽（添加tp参数）
function s.filter2(c,tp)
    return c:IsFaceup() and c:IsControler(1-tp)
end

--发动目标选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then
        return Duel.IsExistingTarget(s.filter1,tp,LOCATION_MZONE,0,1,nil)
            and Duel.IsExistingTarget(s.filter2,tp,0,LOCATION_MZONE,1,nil,tp)
    end
    --选择自己的怪兽
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g1=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_MZONE,0,1,1,nil)
    --选择对方的怪兽
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g2=Duel.SelectTarget(tp,s.filter2,tp,0,LOCATION_MZONE,1,1,nil,tp)
end

--效果发动
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    if #g~=2 then return end
    
    local tc1,tc2
    if g:GetFirst():IsControler(tp) then
        tc1=g:GetFirst()
        tc2=g:GetNext()
    else
        tc1=g:GetNext()
        tc2=g:GetFirst()
    end
    
    --检查目标是否仍然在场且表侧
    if not tc1:IsFaceup() or not tc1:IsRelateToEffect(e)
        or not tc2:IsFaceup() or not tc2:IsRelateToEffect(e) then return end
    
    --记录对方怪兽的攻击力（伤害值）
    local atk2=tc2:GetAttack()
    local tc2_code=tc2:GetOriginalCode()  --获取卡片原始代码用于追踪
    
    --创建持续监测效果
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_LEAVE_FIELD)
    e1:SetLabel(atk2)  --存储伤害值
    e1:SetLabelObject(tc1)  --存储自己的怪兽引用
    e1:SetValue(tc2_code)  --存储对方怪兽的卡片代码
    e1:SetCondition(s.damcon)
    e1:SetOperation(s.damop)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

--伤害触发条件
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local tc1=e:GetLabelObject()
    local tc2_code=e:GetValue()  --获取存储的卡片代码
    
    --检查自己怪兽是否还在场上
    if not tc1 or not tc1:IsFaceup() or not tc1:IsLocation(LOCATION_MZONE) then return false end
    
    --检查离场怪兽中是否有匹配的卡片代码
    return eg:IsExists(function(c,code)
        return c:GetOriginalCode()==code
    end,1,nil,tc2_code)
end

--伤害处理
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local atk2=e:GetLabel()  --获取存储的伤害值
    
    --给予对方那只怪兽攻击力的伤害
    if atk2>0 then
        Duel.Damage(1-tp,atk2,REASON_EFFECT)
    end
end