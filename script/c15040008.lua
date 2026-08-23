-- 异响鸣之神选-则步费岚
-- ID: 15040008
-- 字段：异响鸣 (0x1a3)
local s,id=GetID()
function s.initial_effect(c)
    -- ① 展示自身和额外卡组1只恶魔族·光属性怪兽才能发动，特殊召唤
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 特殊召唤成功时，自己受到500伤害，检索「异响鸣」魔陷
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- ① 发动条件：自己场上没有怪兽，或有「异响鸣」卡存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    local b1 = Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
    local b2 = Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsSetCard,0x1a3),tp,LOCATION_ONFIELD,0,1,nil)
    return b1 or b2
end

-- ① cost：从额外卡组选择1只恶魔族·光属性怪兽与这张卡一起展示
function s.extra_filter(c)
    return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_MONSTER)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.extra_filter,tp,LOCATION_EXTRA,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.extra_filter,tp,LOCATION_EXTRA,0,1,1,nil)
    local rg=Group.FromCards(c,g:GetFirst())
    Duel.ConfirmCards(1-tp,rg)
end

-- ① 目标：特殊召唤自身
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

-- ① 操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ② 检索目标：卡组的「异响鸣」魔法·陷阱卡
function s.thfilter(c)
    return c:IsSetCard(0x1a3) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,500)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ② 操作：先受500伤害，再检索
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(tp,500,REASON_EFFECT)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end