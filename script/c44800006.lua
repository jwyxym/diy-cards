-- 魔妖仙兽 颪天邪风
-- ID: 44800006
-- 字段: 0xb3
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xb3),2,2)

    -- ① 链接召唤成功时回收素材中通常召唤的怪兽，风属性自肃
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.rectg)
    e1:SetOperation(s.recop)
    c:RegisterEffect(e1)

    -- ② 场上的这张卡除外，检索魔陷，结束阶段回归
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCost(s.rmcost)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- ③ 对方召唤·特殊召唤时，回额外，选双方各1卡回手（不取对象）
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SUMMON_SUCCESS)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+2000)
    e3:SetCondition(s.retcon)
    e3:SetTarget(s.rettg)
    e3:SetOperation(s.retop)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e4)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ① 回收素材中通常召唤的怪兽
function s.recfilter(c)
    return c:IsSummonType(SUMMON_TYPE_NORMAL) and c:IsAbleToHand()
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    local mg=e:GetHandler():GetMaterial()
    if chk==0 then return mg:IsExists(s.recfilter,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,mg,mg:GetCount(),0,0)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
    -- 风属性自肃
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
    local mg=e:GetHandler():GetMaterial()
    local g=mg:Filter(s.recfilter,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
function s.splimit(e,c)
    return not c:IsAttribute(ATTRIBUTE_WIND)
end

-- ② cost：除外自身，注册结束阶段回归
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    local c=e:GetHandler()
    Duel.Remove(c,POS_FACEUP,REASON_COST)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetCountLimit(1)
    e1:SetLabelObject(c)
    e1:SetOperation(s.retop2)
    Duel.RegisterEffect(e1,tp)
end
-- ② 结束阶段回归
function s.retop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetLabelObject()
    if c:IsLocation(LOCATION_REMOVED) then
        Duel.MoveToField(c,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
    end
end
-- ② 检索魔陷
function s.thfilter(c)
    return c:IsSetCard(0xb3) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ③ 对方召唤·特殊召唤时
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- 选自己场上1卡回手
    local g1=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,0,nil)
    if #g1>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local sg1=g1:Select(tp,1,1,nil)
        Duel.SendtoHand(sg1,nil,REASON_EFFECT)
    end
    -- 选对方场上1卡回手
    local g2=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,nil)
    if #g2>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
        local sg2=g2:Select(tp,1,1,nil)
        Duel.SendtoHand(sg2,nil,REASON_EFFECT)
    end
    -- 自己回额外
    if c:IsRelateToEffect(e) and c:IsAbleToDeck() then
        Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end