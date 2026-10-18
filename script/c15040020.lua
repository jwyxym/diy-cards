-- 转校生 丰川祥子
-- ID: 15040020
-- 「羽丘」字段：0xb13
-- 「丰川祥子」字段：0xb10
local s,id=GetID()
function s.initial_effect(c)
    -- ① 自己场上有「羽丘」卡时，从手卡特殊召唤（1回合1次）
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- ② 持有这张卡作为超量素材的超量怪兽得到效果（使用 EFFECT_TYPE_XMATERIAL）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
    e2:SetCountLimit(1)
    e2:SetCost(s.thcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end

-- ① 条件：自己场上有「羽丘」卡
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsSetCard,0xb13),tp,LOCATION_ONFIELD,0,1,nil)
end

-- ② 费用：取除1个超量素材
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
    c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- ② 检索对象：「丰川祥子」怪兽
function s.thfilter(c)
    return c:IsSetCard(0xb10) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    -- 失去500基本分
    Duel.SetLP(tp,Duel.GetLP(tp)-500)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end