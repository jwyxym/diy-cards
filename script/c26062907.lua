-- 属于我们的歌 长崎爽世
-- ID: 26062907
-- 记述「春日影」(26062911)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)  -- 声明卡名记述

    -- 同调召唤限制
    c:EnableReviveLimit()
    aux.AddSynchroProcedure(c, nil, aux.FilterBoolFunction(aux.IsCodeListed,26062911), 1)

    -- ① 特殊召唤成功时，检索或堆墓（发动后本回合不能除外）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)

    -- ② 双方回合，墓地怪兽回卡组，可选破坏（1回合1次，与①共享）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.operation2)
    c:RegisterEffect(e2)
end

-- ① 目标
function s.filter1(c)
    return aux.IsCodeListed(c,26062911) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    -- 自肃：本回合自己不能把卡除外
    local e0=Effect.CreateEffect(e:GetHandler())
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_CANNOT_REMOVE)
    e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e0:SetTargetRange(1,0)
    e0:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e0,tp)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
    local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    local b1=tc:IsAbleToHand()
    local b2=tc:IsAbleToGrave()
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    elseif b1 then
        op=0
    elseif b2 then
        op=1
    else return end
    if op==0 and b1 then
        Duel.SendtoHand(tc,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,tc)
    elseif op==1 and b2 then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end

-- ② 目标：自己墓地1只记述「春日影」怪兽
function s.filter2(c)
    return aux.IsCodeListed(c,26062911) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter2(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter2,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
        if tc:IsLocation(LOCATION_DECK)
            and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
            local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
            if #dg>0 then
                Duel.Destroy(dg,REASON_EFFECT)
            end
        end
    end
end