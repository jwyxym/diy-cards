-- 傍死的安纳提玛·徒姬
-- 卡号：65200090
-- 属性：暗 / 种族：不死族 / 等级：7 / 攻击：2500 / 守备：2000
-- 规则上当作「<梦魇>」卡使用（由 EFFECT_ADD_SETCODE 实现）
-- 效果文本请存入数据库 texts 表，脚本通过 aux.Stringid 引用。

local s,id=GetID()
local SET_NIGHTMARE=0x32a

function s.initial_effect(c)
    -- 规则上当作「<梦魇>」卡使用
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetRange(LOCATION_ALL)
    e0:SetValue(SET_NIGHTMARE)
    c:RegisterEffect(e0)

    -- ① 召唤成功时发动
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))   -- 对应 str1
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- ① 被<梦魇>卡的效果特殊召唤时发动
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))   -- 对应 str1
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.spcon1)
    e2:SetTarget(s.tg1)
    e2:SetOperation(s.op1)
    c:RegisterEffect(e2)

    -- ② 双方战斗阶段，解放1只怪兽，全场不死族攻守+500
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))   -- 对应 str2
    e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(s.con2)
    e3:SetCost(s.cost2)
    e3:SetTarget(s.tg2)
    e3:SetOperation(s.op2)
    c:RegisterEffect(e3)

    -- ③ 双方主要阶段，解放自己场上这张卡以外的1只不死族，
    --    从卡组特召不同名的2星以下<梦魇>怪兽并无效化
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))   -- 对应 str3
    e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetHintTiming(0,TIMING_MAIN_END)
    e4:SetCountLimit(1,id+200)
    e4:SetCondition(s.con3)
    e4:SetCost(s.cost3)
    e4:SetTarget(s.tg3)
    e4:SetOperation(s.op3)
    c:RegisterEffect(e4)
end

-- ① 特召触发条件：被<梦魇>卡效果特召
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
    return re and re:GetHandler():IsSetCard(SET_NIGHTMARE)
end

-- ① 过滤：2星以下<梦魇>怪兽
function s.filter1(c,e,tp)
    return c:IsSetCard(SET_NIGHTMARE) and c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ① 目标
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- ① 操作
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    -- 自肃：发动后直到回合结束，不是不死族不能特召
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        local tc=g:GetFirst()
        Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
        -- 无效化
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
        local e3=e2:Clone()
        e3:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e3)
        Duel.SpecialSummonComplete()
    end
end

-- ① 自肃限制
function s.splimit(e,c)
    return not c:IsRace(RACE_ZOMBIE)
end

-- ② 条件：战斗阶段
function s.con2(e,tp)
    local ph=Duel.GetCurrentPhase()
    return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- ② Cost：解放自己场上1只怪兽
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
    local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
    Duel.Release(g,REASON_COST)
end
-- ② 目标
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
-- ② 操作：全场不死族+500攻守
function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE))
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(500)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(e2)
    end
end

-- ③ 条件：双方主要阶段
function s.con3(e,tp)
    return Duel.IsMainPhase()
end
-- ③ Cost：解放这张卡以外自己场上1只不死族怪兽
function s.costfilter3(c,e,tp)
    return c:IsReleasable() and c:IsRace(RACE_ZOMBIE) and not c:IsCode(id)
end
function s.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,s.costfilter3,1,nil,e,tp) end
    local g=Duel.SelectReleaseGroup(tp,s.costfilter3,1,1,nil,e,tp)
    local code=g:GetFirst():GetCode()
    Duel.Release(g,REASON_COST)
    e:SetLabel(code)
end
-- ③ 过滤：2星以下<梦魇>且不同名
function s.filter3(c,e,tp,code)
    return c:IsSetCard(SET_NIGHTMARE) and c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(code)
end
function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
    local code=e:GetLabel()
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter3,tp,LOCATION_DECK,0,1,nil,e,tp,code) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
    local code=e:GetLabel()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.filter3,tp,LOCATION_DECK,0,1,1,nil,e,tp,code)
    if #g>0 then
        local tc=g:GetFirst()
        Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e2)
        Duel.SpecialSummonComplete()
    end
end