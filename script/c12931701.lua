-- 堕天使 彼列
-- ID: 12931701
-- 字段：堕天使 0xef
local s,id=GetID()
function s.initial_effect(c)
    -- ① 展示手卡自身 + 1只暗属性天使族，特召2只
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost1)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)
    -- ② 主阶段，从卡组堆1张堕天使卡
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.tg2con)
    e2:SetTarget(s.tg2)
    e2:SetOperation(s.op2)
    c:RegisterEffect(e2)
    -- ③ 支付1000LP，复制墓地堕天使魔陷效果后回卡组
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

function s.spfilter1(c,e,tp)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FAIRY)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return not c:IsPublic() and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,c,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
    local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,c,e,tp)
    g:AddCard(c)
    Duel.ConfirmCards(1-tp,g)
    Duel.ShuffleHand(tp)
    g:KeepAlive()
    e:SetLabelObject(g)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetLabelObject(),2,0,0)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local g=e:GetLabelObject()
    if not g then return end
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then g:DeleteGroup() return end
    Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    g:DeleteGroup()
end

function s.otherfilter(c)
    return c:IsFaceup() and c:IsSetCard(0xef)
end
function s.tg2con(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.otherfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.tg2filter(c)
    return c:IsSetCard(0xef) and c:IsAbleToGrave()
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tg2filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tg2filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then Duel.SendtoGrave(g,REASON_EFFECT) end
end

-- ③ 复制效果（参考「黄昏の堕天使ルシファー」）
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