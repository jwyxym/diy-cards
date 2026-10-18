-- 属于我们的歌 若叶睦
-- ID: 15040002
-- 记述「春日影」(26062911)
-- 「若叶睦」字段 0xb11
-- 「丰川祥子」字段 0xb10
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)
    c:EnableReviveLimit()

    -- 不能同调召唤，也不能以标准方式从额外卡组特殊召唤（仅限额外卡组）
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e0:SetCode(EFFECT_SPSUMMON_CONDITION)
    e0:SetValue(s.splimit)
    c:RegisterEffect(e0)

    -- 自身特殊召唤手续：把「若叶睦」怪兽和「春日影」记述怪兽各1只送去墓地
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_EXTRA)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ① 二速解放自身，随机除外对方1张手牌
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCondition(s.spcon2)
    e2:SetCost(s.rccost)
    e2:SetTarget(s.rctg)
    e2:SetOperation(s.rcop)
    c:RegisterEffect(e2)

    -- ② 墓地回收效果
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.rettg)
    e3:SetOperation(s.retop)
    c:RegisterEffect(e3)
end

-- 限制仅对从额外卡组特殊召唤生效（返回 true 表示允许，false 表示禁止）
function s.splimit(e,se,sp,st)
    return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

-- 特殊召唤条件：需要有「若叶睦」怪兽和「春日影」记述怪兽各1只
-- 由于手续会把2只怪兽送去墓地并腾出空间，因此不需要检查场上是否有空位
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g1=Duel.GetMatchingGroup(s.filter_yu,tp,LOCATION_MZONE,0,nil)
    local g2=Duel.GetMatchingGroup(s.filter_spring,tp,LOCATION_MZONE,0,nil)
    if #g1==0 or #g2==0 then return false end
    if #g1==1 and #g2==1 and g1:GetFirst()==g2:GetFirst() then return false end
    return true
end

function s.filter_yu(c)
    return c:IsFaceup() and c:IsSetCard(0xb11) and c:IsAbleToGrave()
end

function s.filter_spring(c)
    return c:IsFaceup() and aux.IsCodeListed(c,26062911) and c:IsAbleToGrave()
end

-- 选择并记录素材
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g1=Duel.GetMatchingGroup(s.filter_yu,tp,LOCATION_MZONE,0,nil)
    local g2=Duel.GetMatchingGroup(s.filter_spring,tp,LOCATION_MZONE,0,nil)
    if #g1==0 or #g2==0 then return false end
    if #g1==1 and #g2==1 and g1:GetFirst()==g2:GetFirst() then return false end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg1=g1:Select(tp,1,1,nil)
    local tc1=sg1:GetFirst()
    if not tc1 then return false end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg2=g2:Select(tp,1,1,tc1)
    local tc2=sg2:GetFirst()
    if not tc2 then return false end
    local sg=Group.FromCards(tc1,tc2)
    sg:KeepAlive()
    e:SetLabelObject(sg)
    return true
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    if sg and #sg==2 then
        Duel.SendtoGrave(sg,REASON_MATERIAL+REASON_SYNCHRO)
    end
end

-- ① 条件：从额外卡组特殊召唤的这张卡
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end

function s.rccost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.rcop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
    if #g==0 then return end
    local tc=g:RandomSelect(1-tp,1):GetFirst()
    Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
    tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetCountLimit(1)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetLabel(tp)
    e1:SetLabelObject(tc)
    e1:SetCondition(s.rethcon)
    e1:SetOperation(s.rethop)
    e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
    Duel.RegisterEffect(e1,tp)
end
function s.rethcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()~=e:GetLabel() and e:GetLabelObject():GetFlagEffect(id)>0
end
function s.rethop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetLabelObject()
    if tc:IsLocation(LOCATION_REMOVED) then
        Duel.SendtoHand(tc,tc:GetPreviousControler(),REASON_EFFECT+REASON_RETURN)
    end
end

-- ② 墓地效果
function s.recfilter(c)
    return aux.IsCodeListed(c,26062911) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.recfilter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.recfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectTarget(tp,s.recfilter,tp,LOCATION_GRAVE,0,1,3,nil)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
    if #g==0 then return end
    Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
    local has_xiangzi=g:IsExists(Card.IsSetCard,1,nil,0xb10)
    local c=e:GetHandler()
    if has_xiangzi and c:IsRelateToEffect(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.BreakEffect()
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end