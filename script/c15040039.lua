-- 忘却命运之键 Oblivionis
-- ID: 15040039
-- 「赞颂音乐的人偶」(15040037) 卡名记述
-- 「丰川祥子」字段：0xb10
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,15040037)  -- 此卡记述「赞颂音乐的人偶」

    -- ① 从手卡特殊召唤（丢弃1张手卡）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ① 后续自肃（只要这张卡在场上表侧表示存在，只能召唤·特殊召唤记述「赞颂音乐的人偶」的怪兽）
    local e1b=Effect.CreateEffect(c)
    e1b:SetType(EFFECT_TYPE_FIELD)
    e1b:SetCode(EFFECT_CANNOT_SUMMON)
    e1b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1b:SetRange(LOCATION_MZONE)
    e1b:SetTargetRange(1,0)
    e1b:SetTarget(s.sumlimit)
    c:RegisterEffect(e1b)

    local e1c=Effect.CreateEffect(c)
    e1c:SetType(EFFECT_TYPE_FIELD)
    e1c:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1c:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1c:SetRange(LOCATION_MZONE)
    e1c:SetTargetRange(1,0)
    e1c:SetTarget(s.sumlimit)
    c:RegisterEffect(e1c)

    -- ② 主要阶段：当作永续陷阱放置，从卡组特召1只恶魔族以外的记述「赞颂音乐的人偶」的怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCondition(s.trapcon)
    e2:SetTarget(s.traptg)
    e2:SetOperation(s.trapop)
    c:RegisterEffect(e2)

    -- ③ 当作永续陷阱使用时，双方主要阶段：取除1个超量素材，特召这张卡
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_SZONE)
    e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e3:SetCountLimit(1,id+1000)
    e3:SetCondition(s.spcon3)
    e3:SetCost(s.spcost3)
    e3:SetTarget(s.sptg3)
    e3:SetOperation(s.spop3)
    c:RegisterEffect(e3)
end

-- ① 条件：自己场上不存在「赞颂音乐的人偶」记述以外的表侧表示怪兽
function s.nonfilter(c)
    return c:IsFaceup() and not aux.IsCodeListed(c,15040037)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and not Duel.IsExistingMatchingCard(s.nonfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c,REASON_SPSUMMON)
end
-- ① 选择丢弃的手卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,c,REASON_SPSUMMON)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local tc=g:SelectUnselect(nil,tp,false,true,1,1)
    if tc then
        e:SetLabelObject(tc)
        return true
    else return false end
end
-- ① 操作：丢弃手卡
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local tc=e:GetLabelObject()
    Duel.SendtoGrave(tc,REASON_SPSUMMON+REASON_DISCARD)
end

-- ① 自肃：只能召唤/特殊召唤记述「赞颂音乐的人偶」的怪兽
function s.sumlimit(e,c)
    if c:IsLocation(LOCATION_EXTRA) then return false end
    return not aux.IsCodeListed(c,15040037)
end

-- ② 条件：主要阶段
function s.trapcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()&(PHASE_MAIN1+PHASE_MAIN2)~=0
end

-- ② 特召对象：恶魔族以外的、记述「赞颂音乐的人偶」的怪兽
function s.trapfilter(c,e,tp)
    return aux.IsCodeListed(c,15040037) and c:IsType(TYPE_MONSTER)
        and not c:IsRace(RACE_FIEND)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.traptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.trapfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- ② 操作：当作永续陷阱放置，特召怪兽，然后自肃
function s.trapop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or not c:IsLocation(LOCATION_MZONE) then return end
    -- 作为永续陷阱放置到魔法与陷阱区域
    if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        local e0=Effect.CreateEffect(c)
        e0:SetType(EFFECT_TYPE_SINGLE)
        e0:SetCode(EFFECT_CHANGE_TYPE)
        e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e0:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
        e0:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
        c:RegisterEffect(e0)
    end

    -- 从卡组特召1只恶魔族以外的记述怪兽
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.trapfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end

    -- 自肃：本回合只能特殊召唤记述「赞颂音乐的人偶」或「丰川祥子」怪兽（额外卡组除外）
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit2)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.splimit2(e,c)
    if c:IsLocation(LOCATION_EXTRA) then return false end
    return not (aux.IsCodeListed(c,15040037) or c:IsSetCard(0xb10))
end

-- ③ 条件：这张卡作为永续陷阱使用，主要阶段
function s.spcon3(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsType(TYPE_TRAP) then return false end
    return Duel.GetCurrentPhase()&(PHASE_MAIN1+PHASE_MAIN2)~=0
end

-- ③ cost：取除自己场上1个超量素材
function s.ovfilter(c)
    return c:IsType(TYPE_XYZ) and c:GetOverlayCount()>0
end
function s.spcost3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.ovfilter,tp,LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
    local g=Duel.SelectMatchingCard(tp,s.ovfilter,tp,LOCATION_MZONE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        tc:RemoveOverlayCard(tp,1,1,REASON_COST)
    end
end

-- ③ 目标
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- ③ 操作：特召这张卡
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_SZONE) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end