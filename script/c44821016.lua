-- 为抵达未来，「Song i am」！
-- ID: 44821016
-- 永续陷阱
-- 记述「Roselia」(44821000)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,44821000)  -- 此卡记述「Roselia」

    -- 盖放回合可发动（自己场上有记述「Roselia」的融合怪兽）
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e0:SetCondition(s.actcon)
    c:RegisterEffect(e0)

    -- 卡名1回合只能发动1张
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    c:RegisterEffect(e1)

    -- ① 场上只能有1张表侧表示存在
    c:SetUniqueOnField(1,0,id)

    -- ② 1回合1次，以墓地·除外3只记述「Roselia」怪兽为对象，回卡组下面，抽1（二速）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.tdtg)
    e2:SetOperation(s.tdop)
    c:RegisterEffect(e2)

    -- ③-1 被记述「Roselia」的卡效果送去墓地时，记录回合数并设置 Flag
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetOperation(s.regop)
    c:RegisterEffect(e3)

    -- ③-2 下个回合的准备阶段，将此卡表侧放置
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e4:SetRange(LOCATION_GRAVE)
    e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e4:SetCountLimit(1)
    e4:SetCondition(s.setcon)
    e4:SetOperation(s.setop)
    e4:SetLabelObject(e3)
    c:RegisterEffect(e4)
end

-- 盖放回合可发动条件：自己场上有记述「Roselia」的融合怪兽
function s.actfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_FUSION) and aux.IsCodeListed(c,44821000)
end
function s.actcon(e)
    return Duel.IsExistingMatchingCard(s.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

-- ② 对象：自己墓地·除外的3只记述「Roselia」的怪兽
function s.tdfilter(c)
    return aux.IsCodeListed(c,44821000) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,nil)
        and Duel.IsPlayerCanDraw(tp,1) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,3,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end

-- ② 操作：按喜欢的顺序回到卡组下面，然后抽1
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local sg=g:Select(tp,3,3,nil)
    if #sg==3 then
        if Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
            Duel.BreakEffect()
            Duel.Draw(tp,1,REASON_EFFECT)
        end
    end
end

-- ③-1 记录回合数并设置 Flag
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsLocation(LOCATION_GRAVE) then return end
    if not re then return end
    local rc=re:GetHandler()
    if not (rc and aux.IsCodeListed(rc,44821000)) then return end
    e:SetLabel(Duel.GetTurnCount())
    c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
end

-- ③-2 条件：在墓地、有 Flag、且已过了至少一个回合
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsLocation(LOCATION_GRAVE) then return false end
    if c:GetFlagEffect(id)==0 then return false end
    return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount()
end

-- ③-2 操作：将卡从墓地以表侧表示放置到魔法与陷阱区域
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsLocation(LOCATION_GRAVE) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end