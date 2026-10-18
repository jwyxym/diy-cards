--姬装战线·反制
--字段：姬装战线（0xFA1）

local s,id=GetID()
local SET_KISOUSEN=0xFA1

function s.initial_effect(c)
    --①：自己场上有「姬装战线」同调怪兽存在时，怪兽的效果·魔法·陷阱卡的发动无效并破坏。
    --那之后，可以从自己的墓地·除外状态把1只「姬装战线」怪兽特殊召唤。
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition1)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)
    
    --②：盖放的这张卡被效果破坏的场合才能发动。这张卡加入手卡。
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.condition2)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.operation2)
    c:RegisterEffect(e2)
end

function s.syncfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_KISOUSEN) and c:IsType(TYPE_SYNCHRO)
end

function s.condition1(e,tp,eg,ep,ev,re,r,rp)
    -- 反击陷阱：可无效的连锁 + 自己场上有姬装战线同调怪兽
    return Duel.IsChainNegatable(ev)
        and Duel.IsExistingMatchingCard(s.syncfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(SET_KISOUSEN) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    
    -- 无效发动
    if not Duel.NegateActivation(ev) then return end
    
    -- 破坏
    if rc:IsRelateToEffect(re) then
        Duel.Destroy(rc,REASON_EFFECT)
    end
    
    -- 那之后，可以从墓地·除外特招姬装战线怪兽
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
    if #g==0 then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
    
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,1,1,nil)
    if #sg>0 then
        Duel.SpecialSummon(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.condition2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsPreviousLocation(LOCATION_SZONE)
        and c:IsPreviousPosition(POS_FACEDOWN)
        and c:IsReason(REASON_EFFECT)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsAbleToHand() then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    end
end
