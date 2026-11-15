-- 殉鬼之引渡
-- ID: 12940004
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

    -- ① 发动后变为效果怪兽（水族·风·7星·2100/2100）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- ② 作为艮神鬼同调素材送墓
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_BE_MATERIAL)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+2000)
    e2:SetCondition(s.spcon2)
    e2:SetCost(s.cost2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
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
    c:AddMonsterAttribute(TYPE_EFFECT, ATTRIBUTE_WIND, RACE_AQUA, 7, 2100, 2100)
    if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)==0 then return end

    -- ●1 双方回合，以墓地1张陷阱卡为对象：特召为「艮神鬼·役」通常怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,2))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.spgtg1)
    e1:SetOperation(s.spgop1)
    c:RegisterEffect(e1)

    -- ●2 不受对方通常魔法·陷阱效果影响
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCode(EFFECT_IMMUNE_EFFECT)
    e2:SetValue(s.immval)
    c:RegisterEffect(e2)

    -- ●3 不会被魔法效果破坏
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetValue(s.indval)
    c:RegisterEffect(e3)
end

-- ● 效果：选墓地1张陷阱卡
function s.spgtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsType(TYPE_TRAP) end
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_GRAVE,0,1,1,nil,TYPE_TRAP)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spgop1(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end

    -- 变成「艮神鬼·役」通常怪兽（鱼族·暗·1星·调整·0/0）
    tc:AddMonsterAttribute(TYPE_NORMAL+TYPE_TUNER, ATTRIBUTE_DARK, RACE_FISH, 1, 0, 0)
    if Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP_DEFENSE)==0 then return end

    -- 那之后，可以进行1只同调召唤
    local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
    if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sg=g:Select(tp,1,1,nil)
        Duel.SynchroSummon(tp,sg:GetFirst(),nil)
    end

    -- 誓约：本回合只能用1星调整为素材的同调额外特召
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit1)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.splimit1(e,c)
    if not c:IsLocation(LOCATION_EXTRA) then return false end
    return not c:IsType(TYPE_SYNCHRO)
end

-- ● 抗性
function s.immval(e,te)
    if te:GetOwnerPlayer()==e:GetHandlerPlayer() then return false end
    if not te:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return false end
    local rc=te:GetHandler()
    if not rc then return false end
    return rc:IsType(TYPE_NORMAL)
end
function s.indval(e,re)
    if not re then return false end
    return re:IsActiveType(TYPE_SPELL)
end

-- ② 作为艮神鬼同调素材送墓
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=c:GetReasonCard()
    return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
        and rc and rc:IsSetCard(0x1e4)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.gvspfilter(c,e,tp)
    return c:IsSetCard(0x1e4) and c:IsType(TYPE_MONSTER)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.gvspfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.gvspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g==0 then return end
    if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    -- 那之后，可以进行1只艮神鬼同调召唤
    local sg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
    if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
        Duel.BreakEffect()
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tsg=sg:Select(tp,1,1,nil)
        Duel.SynchroSummon(tp,tsg:GetFirst(),nil)
    end
end