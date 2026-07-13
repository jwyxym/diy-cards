-- 无垠轨途 卡洛琳
-- ID: 26051955
-- 字段: 0x903
local s,id=GetID()
function s.initial_effect(c)
    -- 同调召唤：无垠轨途调整 + 调整以外怪兽1只以上
    aux.AddSynchroProcedure(c, aux.FilterBoolFunction(Card.IsSetCard,0x903), aux.NonTuner(nil), 1)
    c:EnableReviveLimit()

    -- ① 解放自身，从墓地特召2只自身以外的「无垠轨途」怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 自己·对方的准备阶段，手卡2张回卡组，抽2
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.drawcon)
    e2:SetTarget(s.drawtg)
    e2:SetOperation(s.drawop)
    c:RegisterEffect(e2)
end

-- ① cost：解放自身
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
-- ① 过滤：墓地「无垠轨途」且非自身，可特召
function s.spfilter(c,e,tp,code)
    return c:IsSetCard(0x903) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local code = e:GetHandler():GetCode()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2
        and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,2,nil,e,tp,code) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
    local code = e:GetHandler():GetCode()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g = Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp,code)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ② 准备阶段可发动
function s.drawcon(e,tp,eg,ep,ev,re,r,rp)
    return true
end
-- ② 目标：手卡至少2张可回卡组
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ② 操作：选2张手卡回卡组，抽2
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    local g = Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND,0,nil)
    if #g<2 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg = g:Select(tp,2,2,nil)
    if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
        Duel.Draw(tp,2,REASON_EFFECT)
    end
end