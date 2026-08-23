-- 《<梦魇>徒姬》
-- 卡号：65200090
local s,id=GetID()
function s.initial_effect(c)
    -- ① 召唤·特殊召唤成功时发动
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- ② 战斗阶段发动，解放1只怪兽，提升全场不死族500攻守
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(s.atkcon)
    e3:SetCost(s.atkcost)
    e3:SetTarget(s.atktg)
    e3:SetOperation(s.atkop)
    c:RegisterEffect(e3)
end

-- ① 效果
function s.filter(c,e,tp)
    return c:IsSetCard(0x32a) and c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    -- 自肃：直到回合结束，自己不是不死族怪兽不能特殊召唤
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    local ft = Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft<=0 then return end
    local g = Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,e,tp)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg1 = g:Select(tp,1,1,nil)
    local tc1 = sg1:GetFirst()
    Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc1:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_DISABLE_EFFECT)
    tc1:RegisterEffect(e3)
    if ft>1 then
        local g2 = g:Filter(function(c,code) return not c:IsCode(code) end,nil,tc1:GetCode())
        if #g2>0 then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
            local sg2 = g2:Select(tp,1,1,nil)
            local tc2 = sg2:GetFirst()
            Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
            local e4=Effect.CreateEffect(e:GetHandler())
            e4:SetType(EFFECT_TYPE_SINGLE)
            e4:SetCode(EFFECT_DISABLE)
            e4:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc2:RegisterEffect(e4)
            local e5=e4:Clone()
            e5:SetCode(EFFECT_DISABLE_EFFECT)
            tc2:RegisterEffect(e5)
        end
    end
    Duel.SpecialSummonComplete()
end
function s.splimit(e,c)
    return not c:IsRace(RACE_ZOMBIE)
end

-- ② 效果
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    local ph = Duel.GetCurrentPhase()
    return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
    local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
    Duel.Release(g,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g = Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE))
    for tc in aux.Next(g) do
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(500)
        e1:SetReset(RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2 = e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(e2)
    end
end