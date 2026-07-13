--以逸待劳 (45205332)
--永续陷阱卡

local s,id=GetID()

function s.initial_effect(c)
    --永续陷阱发动
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    
    --①效果：主要阶段，自己场上的怪兽全部变成里侧守备表示
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_POSITION)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    e1:SetHintTiming(0,TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.poscon1)
    e1:SetTarget(s.postg1)
    e1:SetOperation(s.posop1)
    c:RegisterEffect(e1)
    
    --②效果：战斗阶段，守备表示怪兽变攻击表示，攻击力上升1200
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.poscon2)
    e2:SetTarget(s.postg2)
    e2:SetOperation(s.posop2)
    c:RegisterEffect(e2)
end

--①效果条件：主要阶段
function s.poscon1(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end

--①效果目标
function s.postg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
    end
end

--①效果处理：全部变成里侧守备表示
function s.posop1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    if #g>0 then
        Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
    end
end

--②效果条件：战斗阶段
function s.poscon2(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end

--②效果目标
function s.postg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,0,1,nil)
    end
end

--②效果处理：守备表示变攻击表示，攻击力上升1200
function s.posop2(e,tp,eg,ep,ev,re,r,rp)
    -- 获取守备表示的怪兽
    local g=Duel.GetMatchingGroup(Card.IsDefensePos,tp,LOCATION_MZONE,0,nil)
    if #g==0 then return end
    
    -- ★★★ 先变攻击表示 ★★★
    Duel.ChangePosition(g,POS_FACEUP_ATTACK)
    
    -- ★★★ 攻击力上升1200（作用于所有自己场上的表侧表示怪兽） ★★★
    local atkg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    local tc=atkg:GetFirst()
    while tc do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(1200)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        tc=atkg:GetNext()
    end
end