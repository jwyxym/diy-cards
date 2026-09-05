-- 《圣夜骑士黄昏祝圣》
-- 卡号：88523625
-- 类型：永续魔法
-- 字段：圣夜骑士 (0x159)
local s,id=GetID()
local SET_HOLY_NIGHT=0x159

function s.initial_effect(c)
    -- 卡的发动
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    e0:SetCountLimit(1,id)
    c:RegisterEffect(e0)

    -- ① 主要阶段发动：检索本家怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id+2)
    e1:SetCondition(s.sumcon)
    e1:SetTarget(s.sumtg)
    e1:SetOperation(s.sumop)
    c:RegisterEffect(e1)

    -- ② 双方回合1次：暗属性怪兽效果发动时，回手光属性 + 特召光属性（绑定）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.eff2con)
    e2:SetTarget(s.eff2tg)
    e2:SetOperation(s.eff2op)
    c:RegisterEffect(e2)

    -- ③ 永续：对方手卡·场上·墓地的怪兽变成暗属性
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(0,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_HAND)
    e3:SetValue(ATTRIBUTE_DARK)
    c:RegisterEffect(e3)
end

-- ① 条件：主要阶段
function s.sumcon(e,tp)
    return Duel.IsMainPhase()
end

-- ① 检索过滤：圣夜骑士怪兽
function s.sumfilter(c)
    return c:IsSetCard(SET_HOLY_NIGHT) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ② 条件：暗属性怪兽效果发动
function s.eff2con(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc and rc:IsAttribute(ATTRIBUTE_DARK) and re:IsActiveType(TYPE_MONSTER)
end

-- ② 目标：确认场上有光属性可回手、手牌有光属性可特召
function s.eff2tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local b1=Duel.IsExistingMatchingCard(s.lightfilter,tp,LOCATION_MZONE,0,1,nil)
        local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
        return b1 and b2
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end

-- ② 操作：先回手光属性，再特召光属性
function s.eff2op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
    local g1=Duel.SelectMatchingCard(tp,s.lightfilter,tp,LOCATION_MZONE,0,1,1,nil)
    if #g1==0 then return end
    if Duel.SendtoHand(g1,nil,REASON_EFFECT)==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g2=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
    if #g2>0 then
        Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ② 回手过滤：场上光属性怪兽
function s.lightfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end

-- ② 特召过滤：手牌光属性怪兽
function s.spfilter(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end