-- 极星天 女武神（动画）
--效果：这张卡召唤成功时，从手卡把2张卡送去墓地才能发动。在自己场上把2只「英灵衍生物」（战士族·地·4星·攻/守1000）守备表示特殊召唤。
local s,id=GetID()
function s.initial_effect(c)
    -- 召唤成功时的效果
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

-- 英灵衍生物的Token ID，请替换为实际ID
s.token_id=40844553
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,e:GetHandler()) end
    Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 
            and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) 
            and Duel.IsPlayerCanSpecialSummonMonster(tp,s.token_id,0,TYPE_TOKEN+TYPE_NORMAL,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,s.token_id,0,TYPE_TOKEN+TYPE_NORMAL,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then return end
    
    for i=1,2 do
        local token=Duel.CreateToken(tp,s.token_id)
        if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
            -- 设置衍生物属性（通过Token卡本身设置，一般不需要额外设置）
        end
    end
    Duel.SpecialSummonComplete()
end