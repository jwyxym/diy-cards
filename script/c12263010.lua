--天水：亚马逊
--通常陷阱
--卡密：12263010
--系列字段：0x5244（天水）
local s,id,o=GetID()
function s.initial_effect(c)
    --①效果：破坏对象+对方攻击表示怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,12263010)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --②效果：除外自身，破坏「天水」卡，触发加攻/贯穿/伤害
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,122630101)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.dtg)
    e2:SetOperation(s.dop)
    c:RegisterEffect(e2)
end

--①效果：目标选择（核心修正：完全支持魔陷区LINK/仪式怪兽）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return false end
    if chk==0 then
        -- 筛选自己场上【怪兽区+魔陷区】的表侧LINK怪兽
        local link_filter = function(c)
            return c:IsFaceup() and c:IsType(TYPE_LINK)
        end
        -- 筛选自己场上【怪兽区+魔陷区】的表侧仪式怪兽
        local ritual_filter = function(c)
            return c:IsFaceup() and c:IsType(TYPE_RITUAL)
        end
        -- 必须同时存在LINK、仪式怪兽，且对方有攻击表示怪兽
        return Duel.IsExistingTarget(link_filter,tp,LOCATION_MZONE+LOCATION_SZONE,0,1,nil)
            and Duel.IsExistingTarget(ritual_filter,tp,LOCATION_MZONE+LOCATION_SZONE,0,1,nil)
            and Duel.IsExistingMatchingCard(Card.IsAttackPos,tp,0,LOCATION_MZONE,1,nil)
    end
    -- 选择LINK怪兽（范围：怪兽区+魔陷区）
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g1=Duel.SelectTarget(tp,function(c) return c:IsFaceup() and c:IsType(TYPE_LINK) end,tp,LOCATION_MZONE+LOCATION_SZONE,0,1,1,nil)
    -- 选择仪式怪兽（范围：怪兽区+魔陷区）
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g2=Duel.SelectTarget(tp,function(c) return c:IsFaceup() and c:IsType(TYPE_RITUAL) end,tp,LOCATION_MZONE+LOCATION_SZONE,0,1,1,nil)
    -- 合并两个目标
    local g=Group.CreateGroup()
    g:Merge(g1)
    g:Merge(g2)
    -- 获取对方所有攻击表示怪兽
    local dg=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
    g:Merge(dg)
    -- 设置破坏信息
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

--①效果：发动执行（修复目标获取，兼容魔陷区怪兽）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- 正确获取连锁目标（YGOCore标准写法）
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    -- 过滤出仍在场上的目标（防止连锁中被破坏导致空指针）
    local valid_g = g:Filter(Card.IsRelateToEffect,nil,e)
    -- 获取对方攻击表示怪兽
    local dg=Duel.GetMatchingGroup(Card.IsAttackPos,tp,0,LOCATION_MZONE,nil)
    valid_g:Merge(dg)
    -- 执行破坏
    if #valid_g>0 then
        Duel.Destroy(valid_g,REASON_EFFECT)
    end
end

--②效果：目标选择
function s.dtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsFaceup() and chkc:IsSetCard(0x5244) end
    if chk==0 then
        return Duel.IsExistingTarget(function(c) return c:IsFaceup() and c:IsSetCard(0x5244) end,tp,LOCATION_ONFIELD,0,1,nil)
    end
    -- 选择自己场上1张「天水」卡
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,function(c) return c:IsFaceup() and c:IsSetCard(0x5244) end,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end

--②效果：发动执行
function s.dop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    -- 确认目标存在，执行破坏
    if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
        -- 1. 本回合自己怪兽攻击力+1000
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetTargetRange(LOCATION_MZONE,0)
        e1:SetValue(1000)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        -- 2. 本回合自己怪兽攻击守备怪兽造成贯穿伤害
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_FIELD)
        e2:SetCode(EFFECT_PIERCE)
        e2:SetTargetRange(LOCATION_MZONE,0)
        e2:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e2,tp)
        -- 3. 给与对方1000伤害
        Duel.Damage(1-tp,1000,REASON_EFFECT)
    end
end
