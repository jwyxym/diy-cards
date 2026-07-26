-- 初次的邂逅 丰川祥子
-- ID: 26062901
-- 有「春日影」(26062911)的卡名记述
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)  -- 声明卡名记述

    -- ① 不入连锁的特殊召唤（1回合仅1次）
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 解放自身，从卡组拉最多2只天使族以外的记述有「春日影」卡名的怪兽
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1000)
    e2:SetCost(s.relcost)
    e2:SetTarget(s.reltg)
    e2:SetOperation(s.relop)
    c:RegisterEffect(e2)
end

-- ① 条件：自己场上没有非记述「春日影」卡名的表侧怪兽
function s.spconfilter(c)
    return c:IsFaceup() and not aux.IsCodeListed(c,26062911)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and not Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c,REASON_SPSUMMON)
end
-- ① 选择丢弃的手牌
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
    local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,c,REASON_SPSUMMON)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local tc=g:SelectUnselect(nil,tp,false,true,1,1)
    if tc then
        e:SetLabelObject(tc)
        return true
    else return false end
end
-- ① 执行：丢弃手牌，特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    local tc=e:GetLabelObject()
    Duel.SendtoGrave(tc,REASON_SPSUMMON+REASON_DISCARD)
end

-- ② cost：解放自己
function s.relcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsReleasable() end
    Duel.Release(c,REASON_COST)
end
-- ② 可特殊召唤的怪兽：天使族以外，记述「春日影」卡名
function s.relfilter(c,e,tp)
    return aux.IsCodeListed(c,26062911) and not c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.reltg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
        return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.relop(e,tp,eg,ep,ev,re,r,rp)
    local ft=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE),2)
    if ft<=0 then return end
    local g=Duel.GetMatchingGroup(s.relfilter,tp,LOCATION_DECK,0,nil,e,tp)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=g:Select(tp,1,ft,nil)
    local c=e:GetHandler()
    local tc=sg:GetFirst()
    while tc do
        if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            -- 效果无效
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
            local e2=Effect.CreateEffect(c)
            e2:SetType(EFFECT_TYPE_SINGLE)
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            e2:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e2)
            -- 离场时返回卡组最下方
            local e3=Effect.CreateEffect(c)
            e3:SetType(EFFECT_TYPE_SINGLE)
            e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
            e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e3:SetValue(LOCATION_DECKBOT)
            tc:RegisterEffect(e3,true)
            -- 额外自肃
            local e4=Effect.CreateEffect(c)
            e4:SetType(EFFECT_TYPE_FIELD)
            e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
            e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
            e4:SetRange(LOCATION_MZONE)
            e4:SetTargetRange(1,0)
            e4:SetTarget(s.extralimit)
            e4:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e4)
        end
        tc=sg:GetNext()
    end
    Duel.SpecialSummonComplete()
end

function s.extralimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not aux.IsCodeListed(c,26062911)
end