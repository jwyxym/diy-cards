-- 堕天使 阿撒兹勒
-- ID: 12931705
-- 字段：堕天使 0xef / 禁忌的 0x11d
local s,id=GetID()
function s.initial_effect(c)
    -- ① 丢弃自身，从卡组·墓地特召堕天使
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCondition(s.spcon1)
    e1:SetCost(s.spcost1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)

    -- ② 作为融合素材送墓/除外时，特召自身并回血
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.spcon2)
    e2:SetTarget(s.sptg2)
    e2:SetOperation(s.spop2)
    c:RegisterEffect(e2)
    local e2b=e2:Clone()
    e2b:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e2b)

    -- ③ 复制墓地「禁忌的」速攻魔法效果
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TODECK)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e3:SetCountLimit(1,id+2000)
    e3:SetCost(s.cpcost)
    e3:SetTarget(s.cptg)
    e3:SetOperation(s.cpop)
    c:RegisterEffect(e3)
end

-- ①
function s.faceup_dark_fairy(c)
    return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK)
        and c:IsType(TYPE_FUSION)
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    if not (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) then return false end
    return Duel.IsExistingMatchingCard(s.faceup_dark_fairy,tp,LOCATION_MZONE,0,1,nil)
end
function s.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
function s.spfilter1(c,e,tp)
    return c:IsSetCard(0xef) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(e:GetHandler())
            e2:SetType(EFFECT_TYPE_FIELD)
            e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
            e2:SetTargetRange(1,0)
            e2:SetTarget(s.splimit)
            e2:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e2,tp)
        end
    end
end
function s.splimit(e,c)
    return not c:IsRace(RACE_FAIRY)
end

-- ②
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return bit.band(r,REASON_MATERIAL)~=0 and bit.band(r,REASON_FUSION)~=0
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
        local g1=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_REMOVED,0,nil,RACE_FAIRY)
        local g2=Duel.GetMatchingGroup(Card.IsRace,1-tp,LOCATION_REMOVED,0,nil,RACE_FAIRY)
        local total=#g1+#g2
        if total>0 then
            Duel.Recover(tp,total*500,REASON_EFFECT)
        end
    end
end

-- ③ 复制效果
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end
function s.cpfilter(c)
    return c:IsSetCard(0x11d) and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToDeck()
        and c:CheckActivateEffect(false,true,false)~=nil
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        local te=e:GetLabelObject()
        local tg=te:GetTarget()
        return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
    end
    if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
    Duel.ClearTargetCard()
    g:GetFirst():CreateEffectRelation(e)
    local tg=te:GetTarget()
    if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
    te:SetLabelObject(e:GetLabelObject())
    e:SetLabelObject(te)
    Duel.ClearOperationInfo(0)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
    local te=e:GetLabelObject()
    if not te then return end
    if not te:GetHandler():IsRelateToChain() then return end
    e:SetLabelObject(te:GetLabelObject())
    local op=te:GetOperation()
    if op then op(e,tp,eg,ep,ev,re,r,rp) end
    Duel.BreakEffect()
    Duel.SendtoDeck(te:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end