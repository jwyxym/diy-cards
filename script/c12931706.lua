-- 堕天使 厄瑞玻斯
-- ID: 12931706
-- 字段：堕天使 0xef
local s,id=GetID()
function s.initial_effect(c)
    -- ① 天使族·暗属性召唤·特召时，从手卡/墓地特召自身，堆墓/检索
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE+CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon1)
    e1:SetTarget(s.sptg1)
    e1:SetOperation(s.spop1)
    c:RegisterEffect(e1)
    local e1b=e1:Clone()
    e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e1b)

    -- ② 自己场上堕天使被破坏时，除外手卡/墓地的自身，特召除外区堕天使
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.rmcon)
    e2:SetCost(s.rmcost)
    e2:SetTarget(s.rmtg2)
    e2:SetOperation(s.rmop2)
    c:RegisterEffect(e2)

    -- ③ 复制墓地堕天使魔陷效果（双方回合）
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
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.darkfairy_filter,1,nil,tp)
end
function s.darkfairy_filter(c,tp)
    return c:IsControler(tp) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local from_grave = c:IsLocation(LOCATION_GRAVE)
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    if from_grave then
        if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
            if #g>0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
            end
        end
    else
        if Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
            if #g>0 then
                Duel.SendtoGrave(g,REASON_EFFECT)
            end
        end
    end
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.tgfilter(c)
    return c:IsSetCard(0xef) and c:IsAbleToGrave()
end
function s.splimit(e,c)
    return not c:IsRace(RACE_FAIRY)
end

-- ②
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.dest_filter,1,nil,tp)
end
function s.dest_filter(c,tp)
    return c:IsSetCard(0xef) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler(tp)
        and bit.band(c:GetReason(),REASON_BATTLE+REASON_EFFECT)~=0
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
function s.rmfilter2(c,e,tp)
    return c:IsSetCard(0xef) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end

-- ③ 复制效果
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end
function s.cpfilter(c)
    return c:IsSetCard(0xef) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
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