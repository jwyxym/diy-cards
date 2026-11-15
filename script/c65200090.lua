local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c, 65200090)
    
    -- ① 召唤/记述卡效果特召
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCondition(s.spcon)
    c:RegisterEffect(e2)

    -- ② 双方主阶：解放不死族适用①
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMING_MAIN_END)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.maincon) -- ★ 新增：主阶段判定
    e3:SetCost(s.cost_zombie)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

    -- ③ 双方战阶：解放怪兽加攻
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,2))
    e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
    e4:SetCountLimit(1,id+2)
    e4:SetCondition(s.battlecon)
    e4:SetCost(s.cost_any)
    e4:SetTarget(s.atktg)
    e4:SetOperation(s.atkop)
    c:RegisterEffect(e4)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return re and (re:GetHandler():IsCode(id) or aux.IsCodeListed(re:GetHandler(), id))
end

-- ★ 新增：严格判定双方主要阶段
function s.maincon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsMainPhase()
end

-- ★ 新增：严格判定战斗阶段
function s.battlecon(e,tp,eg,ep,ev,re,r,rp)
    local ph=Duel.GetCurrentPhase()
    return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end

function s.spfilter(c,e,tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ★ 核心修复：移除了 GetLocationCount>0 的判定，只要卡组有卡，满场也能发动（反正Cost会解放）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

-- ★ 核心修复：在操作阶段（此时怪兽已解放，必定有空位）再判定格子
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
            if not aux.IsCodeListed(tc, id) and not tc:IsCode(id) then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_FIELD)
                e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
                e1:SetCode(EFFECT_CANNOT_ACTIVATE)
                e1:SetTargetRange(1,0)
                e1:SetValue(function(e,c) return c:IsCode(tc:GetCode()) end)
                e1:SetReset(RESET_PHASE+PHASE_END)
                Duel.RegisterEffect(e1,tp)
            end
        end
    end
end

function s.cost_zombie(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),1,e:GetHandler()) end
    local g=Duel.SelectReleaseGroup(tp,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),1,1,e:GetHandler())
    Duel.Release(g,REASON_COST)
end

function s.cost_any(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,e:GetHandler()) end
    local g=Duel.SelectReleaseGroup(tp,nil,1,1,e:GetHandler())
    Duel.Release(g,REASON_COST)
end

function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),tp,LOCATION_MZONE,0,1,nil) end
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.FilterBoolFunction(Card.IsFaceup,RACE_ZOMBIE),tp,LOCATION_MZONE,0,nil)
    for tc in aux.Next(g) do
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(500)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        tc:RegisterEffect(e2)
    end
end