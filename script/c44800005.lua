-- 魔妖仙兽 镰柱门神
-- ID: 44800005
-- 字段: 0xb3
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xb3),3,3)

    -- ① 链接召唤成功时回收素材中通常/灵摆召唤的怪兽，并可以追加召唤
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

    -- ② 双方回合，回额外，弹双方各1卡回卡组（不取对象）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCost(s.tdcost)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ① 回收素材：通常召唤或灵摆召唤的本家怪兽
function s.recfilter(c)
    return c:IsSetCard(0xb3) and c:IsAbleToHand()
        and (c:IsSummonType(SUMMON_TYPE_NORMAL) or c:IsSummonType(SUMMON_TYPE_PENDULUM))
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    local mg=e:GetHandler():GetMaterial()
    if chk==0 then return mg:IsExists(s.recfilter,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,mg,mg:GetCount(),0,0)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
    local mg=e:GetHandler():GetMaterial()
    local g=mg:Filter(s.recfilter,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
        -- 给予额外通常召唤次数
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
        e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
        e1:SetReset(RESET_PHASE+PHASE_END)
        Duel.RegisterEffect(e1,tp)
        -- 立刻询问是否召唤1只「妖仙兽」怪兽
        if Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
            local sg=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
            if #sg>0 then
                Duel.Summon(tp,sg:GetFirst(),true,nil)
            end
        end
    end
end
function s.sumfilter(c)
    return c:IsSetCard(0xb3) and c:IsSummonable(true,nil)
end

-- ② cost：回额外
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
    Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- ② 目标：检查双方场上都有卡可回卡组
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,0,0)
end
-- ② 操作：不取对象，直接选择回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g1 = Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,0,nil)
    if #g1 > 0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg1 = g1:Select(tp,1,1,nil)
        Duel.SendtoDeck(sg1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
    local g2 = Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,nil)
    if #g2 > 0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
        local sg2 = g2:Select(tp,1,1,nil)
        Duel.SendtoDeck(sg2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    end
end