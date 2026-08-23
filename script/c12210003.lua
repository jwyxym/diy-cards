local s,id=GetID()
function s.initial_effect(c)
    -- ①：只要这张卡在怪兽区域存在，对方不能攻击宣言
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(0,LOCATION_MZONE)
    c:RegisterEffect(e1)

    -- ②：这张卡和对方怪兽进行战斗的伤害计算时才能发动1次。攻击力上升对方基本分×0.25
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
    e2:SetCountLimit(99)
    e2:SetCondition(s.atkcon)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)

    -- ③：这张卡在同1次的战斗阶段中可以作4次攻击
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_EXTRA_ATTACK)
    e3:SetValue(3)
    c:RegisterEffect(e3)
end

-- ②效果条件：正在和对方怪兽战斗
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local bc=c:GetBattleTarget()
    return bc and bc:IsControler(1-tp)
end

-- ②效果操作：临时提升攻击力
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
    local lp=Duel.GetLP(1-tp)
    local atkup=math.floor(lp * 0.25)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(atkup)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
    c:RegisterEffect(e1)
end
