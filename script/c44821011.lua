-- 决心的呐喊 白金燐子
-- ID: 44821011
-- 记述「Roselia」(44821000)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,44821000)          -- 此卡记述「Roselia」
    aux.AddMaterialCodeList(c,44821005)  -- 融合素材包含「我，该怎么办… 白金燐子」

    -- 融合召唤：「我，该怎么办… 白金燐子」+ 植物族·暗属性怪兽
    c:EnableReviveLimit()
    aux.AddFusionProcFun2(c,
        aux.FilterBoolFunction(Card.IsCode,44821005),
        function(fc) return fc:IsRace(RACE_PLANT) and fc:IsAttribute(ATTRIBUTE_DARK) and fc:IsType(TYPE_MONSTER) end,
        true)

    -- ① 融合召唤成功时，解放自身，从卡组把2张记述「Roselia」的魔法·陷阱送去墓地，然后丢弃1张手卡
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_HANDES)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.tgcon)
    e1:SetCost(s.tgcost)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    -- ② 只要这张卡在怪兽区域存在，自己场上的融合怪兽不会被效果破坏，不会被对方解放
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_FUSION))
    e2:SetValue(s.indval)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_RELEASE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetTarget(s.releasefilter)
    c:RegisterEffect(e3)
end

-- ① 条件：融合召唤成功
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end

-- ① cost：解放自身
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end

-- ① 送去墓地的对象：记述「Roselia」的魔法·陷阱
function s.tgfilter(c)
    return aux.IsCodeListed(c,44821000) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,2,nil)
            and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end

-- ① 操作
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
    if #g<2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg=g:Select(tp,2,2,nil)
    if #sg<2 then return end
    Duel.SendtoGrave(sg,REASON_EFFECT)

    if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
        Duel.BreakEffect()
        Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD)
    end
end

-- ② 免疫值：只免疫对方的效果
function s.indval(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- ② 不会被对方解放：仅限制对方对自己场上融合怪兽的解放
function s.releasefilter(e,c)
    return c:IsType(TYPE_FUSION)
end