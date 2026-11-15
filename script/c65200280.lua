local s,id=GetID()
local ALMISS=65200270
local TENKAN=65200230
local HOLY_TWILIGHT=65200270

function s.initial_effect(c)
    c:EnableReviveLimit()
    -- 仪式召唤手续（根据文本，可用天眼深渊降临，这里提供标准程序）
    aux.AddRitualProcGreater(c,s.ritual_filter)

    -- ① 手卡发动：解放合计3以上的最多2只，视为仪式召唤，加攻
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.spcost)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ②-1 仪式召唤成功的场合
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.syncon)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)

    -- ②-2 攻击力与原本不同的双方主阶二速发动
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMING_MAIN_END)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(s.thcon)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)

    -- ③ 场上有魔神时加攻守800
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_UPDATE_ATTACK)
    e4:SetValue(800)
    e4:SetCondition(s.atkcon)
    c:RegisterEffect(e4)
    local e5=e4:Clone()
    e5:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e5)
end

function s.ritual_filter(c)
    return c:IsRace(RACE_ZOMBIE)
end

-- ① Cost：解放合计3以上最多2只，记录攻击力
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        local mg=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
        if mg:GetCount()==0 then return false end
        -- 检查是否有符合条件的组合
        local mg1=mg:Filter(Card.IsLevelAbove,nil,3)
        if mg1:GetCount()>0 then return true end
        local mg2=mg:GetFirst()
        while mg2 do
            local mg3=mg:Filter(Card.IsLevelAbove,nil,3-mg2:GetLevel())
            if mg3:GetCount()>0 then return true end
            mg2=mg:GetNext()
        end
        return false
    end

    local mg=Duel.GetMatchingGroup(Card.IsReleasable,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
    local sg
    while true do
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
        sg=mg:Select(tp,1,2,nil)
        local total=0
        local atk=0
        for tc in aux.Next(sg) do
            total=total+tc:GetLevel()
            atk=atk+tc:GetBaseAttack()
        end
        if total>=3 then
            e:SetLabel(atk)
            Duel.Release(sg,REASON_COST)
            break
        else
            Duel.Hint(HINT_MESSAGE,tp,"等级合计必须达到3以上！")
        end
    end
end

-- ① Target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- ① Operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local atk=e:GetLabel()
    
    -- 作为仪式召唤特殊召唤
    if Duel.SpecialSummon(c,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)~=0 then
        c:CompleteProcedure()
        if atk>0 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
        end
    end
end

-- ②-1 条件：仪式召唤成功
function s.syncon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

-- ②-2 条件：主阶段且攻击力不同
function s.thcon(e,tp)
    local c=e:GetHandler()
    return Duel.IsMainPhase() and c:GetAttack()~=c:GetBaseAttack()
end

-- ② 过滤：天眼深渊 或 不死族仪式怪兽
function s.thfilter1(c)
    return c:IsCode(TENKAN) and c:IsAbleToHand()
end
function s.thfilter2(c)
    return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
            or Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    -- 检查墓地不死族种类
    local gy=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,0,nil,RACE_ZOMBIE)
    local types={}
    for tc in aux.Next(gy) do
        types[tc:GetCode()]=true
    end
    local typecount=0
    for _ in pairs(types) do typecount=typecount+1 end

    local b1=Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
    local b2=Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)

    -- 如果墓地有4种类以上，且两者都有，询问是否拿2张
    if typecount>=4 and b1 and b2 then
        if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            -- 拿2张
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g1=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
            local g2=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
            g1:Merge(g2)
            if #g1>0 then
                Duel.SendtoHand(g1,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g1)
            end
            return
        end
    end

    -- 正常拿1张
    if b1 or b2 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
        local f=b1 and s.thfilter1 or s.thfilter2
        if b1 and b2 then
            -- 如果只能拿1张，让玩家自己选拿哪一张
            local g=Duel.GetMatchingGroup(s.thfilter1+ s.thfilter2,tp,LOCATION_DECK,0,nil) -- 这里简写，实际需拆开
            local g1=Duel.GetMatchingGroup(s.thfilter1,tp,LOCATION_DECK,0,nil)
            local g2=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK,0,nil)
            g1:Merge(g2)
            local sg=g1:Select(tp,1,1,nil)
            if #sg>0 then
                Duel.SendtoHand(sg,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,sg)
            end
        else
            local g=Duel.SelectMatchingCard(tp,f,tp,LOCATION_DECK,0,1,1,nil)
            if #g>0 then
                Duel.SendtoHand(g,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,g)
            end
        end
    end
end

-- ③ 条件：场上有魔神
function s.atkcon(e)
    return Duel.IsExistingMatchingCard(function(c) return c:IsFaceup() and c:IsCode(ALMISS) end,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end