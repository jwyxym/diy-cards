-- 赤鬼之怒目
-- ID: 12940008
-- 字段：艮神鬼 0x1e4
local s,id=GetID()
function s.initial_effect(c)
    -- 可以在盖放回合发动（需展示场上其他里侧表示的陷阱卡）
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e0:SetCondition(s.actcon)
    c:RegisterEffect(e0)

    -- ① 发动后变怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- ② 墓地除外自身+1张艮神鬼卡：无效对方效果，特召1星艮神鬼并同调
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

-- 盖放回合发动条件：场上必须有其他里侧表示的陷阱卡
function s.actcon(e)
    local tp=e:GetHandlerPlayer()
    local c=e:GetHandler()
    return Duel.IsExistingMatchingCard(function(gc)
        return gc:IsFacedown() and gc:IsType(TYPE_TRAP)
    end,tp,LOCATION_SZONE,0,1,c)
end

-- ① 发动处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end

    -- 展示满足盖放回合发动的里侧陷阱卡
    local g=Duel.GetMatchingGroup(function(gc)
        return gc:IsFacedown() and gc:IsType(TYPE_TRAP)
    end,tp,LOCATION_SZONE,0,c)
    if #g>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        local sg=g:Select(tp,1,1,nil)
        if #sg>0 then Duel.ConfirmCards(1-tp,sg) end
    end

    -- 变怪兽
    c:AddMonsterAttribute(TYPE_EFFECT, ATTRIBUTE_LIGHT, RACE_ILLUSION, 8, 2000, 2000)
    if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)==0 then return end

    -- ●1 双方主阶：解放这张卡以外1只怪兽，特召属性不同的艮神鬼怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.reltg)
    e1:SetOperation(s.relop)
    c:RegisterEffect(e1)

    -- ●2 不会被魔法效果破坏
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e2:SetValue(function(e,re) return re and re:IsActiveType(TYPE_SPELL) end)
    c:RegisterEffect(e2)

    -- ●2 不会被对方战斗破坏
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e3:SetValue(1)
    c:RegisterEffect(e3)
end

-- ●1 解放效果
function s.reltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsType(TYPE_MONSTER) and chkc:IsReleasable() and chkc~=e:GetHandler() end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(function(c) return c:IsType(TYPE_MONSTER) and c:IsReleasable() end,
            tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local g=Duel.SelectTarget(tp,function(c) return c:IsType(TYPE_MONSTER) and c:IsReleasable() end,
        tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
    Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
end
function s.relspfilter(c,e,tp,attr)
    return c:IsSetCard(0x1e4) and c:IsType(TYPE_MONSTER) and c:GetAttribute()~=attr
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.relop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local attr=tc:GetAttribute()
    if Duel.Release(tc,REASON_EFFECT)==0 then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,function(c) return s.relspfilter(c,e,tp,attr) end,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
end

-- ②
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and Duel.IsChainNegatable(ev)
end
function s.negcostfilter(c)
    return c:IsSetCard(0x1e4) and c:IsAbleToRemoveAsCost()
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemoveAsCost()
        and Duel.IsExistingMatchingCard(s.negcostfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,c) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.negcostfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,c)
    g:AddCard(c)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x1e4) and c:IsType(TYPE_MONSTER) and c:GetLevel()==1
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateEffect(ev)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then return end
    if not Duel.SelectYesNo(tp,aux.Stringid(id,3)) then return end
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if not tc then return end
    if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetValue(LOCATION_REMOVED)
    e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
    tc:RegisterEffect(e1,true)
    local sg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
    if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tsg=sg:Select(tp,1,1,nil)
        Duel.SynchroSummon(tp,tsg:GetFirst(),nil)
    end
end