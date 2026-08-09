-- 属于我们的歌 若叶睦
-- ID: 15040002
-- 记述「春日影」(26062911)
-- 「若叶睦」字段 0xb11
-- 「丰川祥子」字段 0xb10
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)

    -- 同调召唤限制
    c:EnableReviveLimit()
    aux.AddSynchroMixProcedure(c,
        aux.FilterBoolFunction(Card.IsSetCard,0xb11),
        nil, nil,
        aux.Tuner(nil),
        1, 99)

    -- 监听「春日影」发动，给予双方玩家回合标记
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_CHAIN_SOLVED)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.flagcon)
    e0:SetOperation(s.flagop)
    c:RegisterEffect(e0)

    -- 额外召唤手续：解放记述怪兽 + 若叶睦怪兽，当作同调召唤
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_SPSUMMON_PROC)
    e5:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e5:SetRange(LOCATION_EXTRA)
    e5:SetCondition(s.sumpcon)
    e5:SetTarget(s.sumptg)
    e5:SetOperation(s.sumpop)
    c:RegisterEffect(e5)

    -- ① 二速解放自身，随机除外对方1张手牌（从额外卡组特殊召唤的此卡才能发动）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCondition(s.spcon)
    e1:SetCost(s.rccost)
    e1:SetTarget(s.rctg)
    e1:SetOperation(s.rcop)
    c:RegisterEffect(e1)

    -- ② 墓地回收效果
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1,id)
    e2:SetTarget(s.rettg)
    e2:SetOperation(s.retop)
    c:RegisterEffect(e2)
end

-- 监听「春日影」发动，设置双方玩家flag
function s.flagcon(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler():IsCode(26062911) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
    Duel.RegisterFlagEffect(1,id,RESET_PHASE+PHASE_END,0,1)
end

-- 额外召唤手续：条件
function s.sumpcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    if Duel.GetFlagEffect(tp,id)==0 then return false end
    local g=Duel.GetMatchingGroup(s.spfilter_all,tp,LOCATION_MZONE,0,nil)
    return g:FilterCount(s.codefilter,nil)>=1 and g:FilterCount(s.setfilter,nil)>=1
        and g:GetCount()>=2
        and Duel.GetLocationCountFromEx(tp,tp,c)>0
end
function s.codefilter(c)
    return c:IsReleasable() and aux.IsCodeListed(c,26062911)
end
function s.setfilter(c)
    return c:IsReleasable() and c:IsSetCard(0xb11)
end
function s.spfilter_all(c)
    return c:IsReleasable() and (aux.IsCodeListed(c,26062911) or c:IsSetCard(0xb11))
end

-- 选择两只怪兽
function s.sumptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(s.spfilter_all,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local sg=g:Select(tp,2,2,nil)
    if #sg~=2 then return false end
    if sg:FilterCount(s.codefilter,nil)==0 or sg:FilterCount(s.setfilter,nil)==0 then return false end
    sg:KeepAlive()
    e:SetLabelObject(sg)
    return true
end
-- 执行解放（引擎自动特殊召唤）
function s.sumpop(e,tp,eg,ep,ev,re,r,rp,c)
    local sg=e:GetLabelObject()
    if sg and #sg==2 and sg:Filter(Card.IsLocation,nil,LOCATION_MZONE):GetCount()==2 then
        Duel.SendtoGrave(sg,REASON_SPSUMMON)
        -- 引擎会自动从额外卡组特殊召唤此卡，召唤地点为LOCATION_EXTRA
    end
end

-- ① 条件：从额外卡组特殊召唤的此卡（参考時械神祖ヴルガータ）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
end
-- ① cost：解放自身
function s.rccost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsReleasable() end
    Duel.Release(e:GetHandler(),REASON_COST)
end
-- ① 目标：对方手牌存在即可
function s.rctg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- ① 操作：随机除外并设置返回
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