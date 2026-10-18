-- 店长特调 天界悬丝
-- ID: 26052020
-- 字段：暗夜织者 0x912
-- 速攻魔法
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_MAIN_END)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
end

function s.ritfilter(c)
    return c:IsRace(RACE_INSECT) and c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER)
end
function s.ritfilter2(c)
    return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsType(TYPE_RITUAL)
end
function s.revfilter(c,e,tp)
    return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- 手卡·自己场上的怪兽，必须有等级
function s.matfilter(c,tp)
    return c:IsType(TYPE_MONSTER)
        and c:IsLevelAbove(1)
        and c:IsReleasable()
        and (c:IsLocation(LOCATION_HAND)
             or (c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)))
end

-- 检查素材等级是否能正好凑够 rc 的等级
function s.can_ritual(tp,rc)
    local lv=rc:GetLevel()
    if lv<=0 then return false end
    local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,tp)
    g=g:Filter(function(mc) return mc~=rc end,nil)
    local levels={}
    for mc in aux.Next(g) do
        levels[#levels+1]=mc:GetLevel()
    end
    if #levels==0 then return false end
    -- 剪枝：素材总等级不够
    local total=0
    for _,v in ipairs(levels) do total=total+v end
    if total<lv then return false end
    local function can_sum(target, idx)
        if target==0 then return true end
        if target<0 or idx>#levels then return false end
        if can_sum(target-levels[idx], idx+1) then return true end
        return can_sum(target, idx+1)
    end
    return can_sum(lv, 1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1=Duel.IsExistingMatchingCard(function(c) return s.ritfilter(c) and s.can_ritual(tp,c) end,
        tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.ritfilter2,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
    if chk==0 then return b1 or b2 end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    local b1=Duel.IsExistingMatchingCard(function(c) return s.ritfilter(c) and s.can_ritual(tp,c) end,
        tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.ritfilter2,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
    local op=0
    if b1 and b2 then
        op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
    elseif b2 then
        op=1
    end
    if op==0 then
        -- ===== 仪式召唤 =====
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local rg=Duel.SelectMatchingCard(tp,function(c) return s.ritfilter(c) and s.can_ritual(tp,c) end,
            tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
        local rc=rg:GetFirst()
        if not rc then return end
        local lv=rc:GetLevel()

        local sg=Group.CreateGroup()
        local sum=0
        while sum<lv do
            local remain=lv-sum
            local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,tp)
            g=g:Filter(function(mc) return mc~=rc and not sg:IsContains(mc) and mc:GetLevel()<=remain end,nil)
            if g:GetCount()==0 then return end
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
            local sel=g:Select(tp,1,1,nil)
            local sc=sel:GetFirst()
            if not sc then return end
            sg:AddCard(sc)
            sum=sum+sc:GetLevel()
        end
        if sum~=lv then return end

        rc:SetMaterial(sg)
        Duel.Release(sg,REASON_COST+REASON_MATERIAL+REASON_RITUAL)
        if Duel.SpecialSummon(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)~=0 then
            rc:CompleteProcedure()
        end
    else
        -- ===== 墓地苏生 =====
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
        local tc=g:GetFirst()
        if tc then
            if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_CANNOT_ATTACK)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
                tc:RegisterEffect(e1)
            end
        end
    end
end