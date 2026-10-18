-- 「死亡」的子弹
-- ID: 15040016
-- 字段：千早爱音 (0xb12)
local s,id=GetID()
function s.initial_effect(c)
    -- 同调召唤限制：调整 + 调整以外的怪兽1只以上
    c:EnableReviveLimit()
    aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)

    -- ① 不会被战斗破坏
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)

    -- ② 无效对方怪兽效果，破坏，累计发动次数（1回合最多2次）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(2,id)          -- 1回合最多使用2次
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

    -- ③ 基本分为100时，解放自身回复3900并检索光属性魔法师族怪兽（决斗中1次）
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(1,id+1,EFFECT_COUNT_CODE_DUEL)  -- 决斗中只能使用1次
    e3:SetCondition(s.reccon)
    e3:SetCost(s.reccost)
    e3:SetTarget(s.rectg)
    e3:SetOperation(s.recop)
    c:RegisterEffect(e3)
end

-- ② 条件：对方发动的怪兽效果
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- ② cost：从手卡除外1张「千早爱音」卡
function s.cfilter(c)
    return c:IsSetCard(0xb12) and c:IsAbleToRemoveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end
-- ② 操作：无效并破坏，然后累计发动次数
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
    -- 累计本场决斗中②效果的发动次数
    Duel.RegisterFlagEffect(tp,id,0,0,1)
    local ct=Duel.GetFlagEffect(tp,id)
    if ct>=6 then
        -- 达到6次后，自己或对方基本分变为100
        local p=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
        if p==0 then
            Duel.SetLP(tp,100)
        else
            Duel.SetLP(1-tp,100)
        end
    end
end

-- ③ 条件：自己基本分为100
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetLP(tp)==100
end
-- ③ cost：解放自身
function s.reccost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
-- ③ 检索光属性·魔法师族怪兽
function s.thfilter(c)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
function s.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,3900)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③ 操作：回复3900，然后可选检索
function s.recop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Recover(tp,3900,REASON_EFFECT)
    local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
    if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #sg>0 then
            Duel.SendtoHand(sg,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,sg)
        end
    end
end