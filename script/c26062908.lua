-- 属于我们的歌 高松灯
-- ID: 26062908
-- 记述「春日影」(26062911)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)  -- 声明卡名记述

    -- 同调召唤限制：“跟大家不一样 高松灯” + 同调怪兽1只以上
    c:EnableReviveLimit()
    aux.AddSynchroProcedure(c,
        aux.FilterBoolFunction(Card.IsCode,26062902),           -- 跟大家不一样 高松灯
        aux.FilterBoolFunction(Card.IsType,TYPE_SYNCHRO), 1)    -- 同调怪兽1只以上

    -- ① 在自己·对手回合，以自己墓地最多2只记述怪兽为对象，回卡组，然后可选盖放等量表侧怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TODECK)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)

    -- ② 只要自己场上存在“属于我们的歌 丰川祥子”与“春日影”，自己场上的记述怪兽不会成为对方效果的对象
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(aux.TargetBoolFunction(aux.IsCodeListed,26062911))
    e2:SetValue(s.tgval)
    c:RegisterEffect(e2)
end

-- ① 对象：自己墓地最多2只记述「春日影」的怪兽（必须是怪兽）
function s.filter1(c)
    return aux.IsCodeListed(c,26062911) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter1(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter1,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.filter1,tp,LOCATION_GRAVE,0,1,2,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    local ct=g:GetCount()
    if ct==0 then return end
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    -- 统计实际回到卡组的数量
    local rct=0
    local tc=g:GetFirst()
    while tc do
        if tc:IsLocation(LOCATION_DECK) then rct=rct+1 end
        tc=g:GetNext()
    end
    if rct>0 and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)
        local sg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,rct,rct,nil)
        if #sg>0 then
            Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
        end
    end
end

-- ② 对象抗性的值函数：检查场上同时存在“属于我们的歌 丰川祥子”和“春日影”，且效果来自对方
function s.tgval(e,re,rp)
    local tp=e:GetHandlerPlayer()
    return rp==1-tp
        and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_MZONE,0,1,nil,26062906)
        and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,26062911)
end