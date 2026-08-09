-- 新星同盟 彩窗三魔契
-- ID: 26051960
-- 字段: 0x902
local s,id=GetID()
function s.initial_effect(c)
    -- 场地魔法卡规则
    c:SetUniqueOnField(1,0,id)

    -- ① 发动时盖放魔陷
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)  -- 同名卡一回合只能发动1张
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)

    -- ② 永续降攻
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetCondition(s.atkcon)
    e2:SetValue(-100)
    c:RegisterEffect(e2)

    -- ③ 特召时升攻
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_ATKCHANGE)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCountLimit(1,id+1)  -- 1回合1次
    e3:SetCondition(s.atkupcon)
    e3:SetOperation(s.atkupop)
    c:RegisterEffect(e3)
end

-- ① 一回合一次（标记法）
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end

-- ① 盖放过滤
function s.setfilter(c)
    return c:IsSetCard(0x902) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and not c:IsForbidden()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g:GetFirst())
    end
end

-- 自定义过滤：表侧「新星同盟」怪兽（替代 aux.FilterFaceup）
function s.faceupfilter(c)
    return c:IsFaceup() and c:IsSetCard(0x902)
end

-- ② 条件：自己场上有「新星同盟」怪兽（表侧）
function s.atkcon(e)
    return Duel.IsExistingMatchingCard(s.faceupfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

-- ③ 条件：自己场上有「新星同盟」怪兽特殊召唤
function s.atkupcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.atkfilter,1,nil,tp)
end
function s.atkfilter(c,tp)
    return c:IsSetCard(0x902) and c:IsControler(tp)
end
-- ③ 操作：自己场上怪兽攻击力上升500
function s.atkupop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end