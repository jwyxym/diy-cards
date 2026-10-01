-- 掌握天空命运的少女·露莉亚
-- ID: 44810211
-- 融合/调整/1星/光/魔法师/100/100
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- 融合素材：魔法师族怪兽×2
    aux.AddFusionProcFunRep(c, s.mfilter, 2, true)

    -- 替代方式特殊召唤
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.spscon)
    e0:SetOperation(s.spop)
    e0:SetValue(SUMMON_VALUE_SELF)
    c:RegisterEffect(e0)

    -- ① 特殊召唤时：送墓1只怪兽，检索同种族不同属性7星以上可通常召唤怪兽
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost1)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    -- ② 战斗破坏耐性
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetValue(s.indval)
    c:RegisterEffect(e2)
end

-- 融合素材过滤：魔法师族
function s.mfilter(c)
    return c:IsRace(RACE_SPELLCASTER)
end

-- 替代召唤条件
function s.spscon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    if #g<2 then return false end
    local tc=g:GetFirst()
    while tc do
        local att=tc:GetAttribute()
        local race=tc:GetRace()
        local g2=g:Filter(function(gc)
            return gc:GetAttribute()==att and gc:GetRace()~=race
        end, nil)
        if #g2>0 then return true end
        tc=g:GetNext()
    end
    return false
end

-- 替代召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
    if #g1==0 then return end
    local tc1=g1:GetFirst()
    local att=tc1:GetAttribute()
    local race=tc1:GetRace()
    local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,tc1)
    g2=g2:Filter(function(gc) return gc:GetAttribute()==att and gc:GetRace()~=race end, nil)
    if #g2==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg2=g2:Select(tp,1,1,nil)
    local mg=g1:Clone()
    mg:Merge(sg2)
    Duel.SendtoGrave(mg, REASON_EFFECT+REASON_MATERIAL)
    Duel.SpecialSummon(c, SUMMON_VALUE_SELF, tp, tp, false, false, POS_FACEUP)
end

-- ① cost：把这张卡以外的自己手卡·场上1只怪兽送去墓地
function s.costfilter(c, e)
    return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and c~=e:GetHandler()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,e:GetHandler(),e) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,e:GetHandler(),e)
    local tc=g:GetFirst()
    -- 保存种族和属性到 flag（RESET_CHAIN 在连锁结束时清除）
    e:GetHandler():RegisterFlagEffect(id+100,RESET_CHAIN,0,1,tc:GetRace())
    e:GetHandler():RegisterFlagEffect(id+200,RESET_CHAIN,0,1,tc:GetAttribute())
    Duel.SendtoGrave(g, REASON_COST)
end

-- ① target：只做基本检查
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.anyfilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.anyfilter(c)
    return c:IsLevelAbove(7) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end

-- 【修正】① 过滤：同种族、不同属性、7星以上、可以通常召唤
function s.thfilter(c,race,att)
    if not (c:IsLevelAbove(7) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()) then return false end
    if not (c:IsRace(race) and not c:IsAttribute(att)) then return false end
    -- 排除额外卡组怪兽和仪式怪兽
    if c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK+TYPE_RITUAL) then return false end
    -- 【关键】排除自身带有「不能通常召唤」限制的怪兽
    if c:IsStatus(STATUS_NO_SUMMON) then return false end
    if c:IsStatus(STATUS_SPSUMMON_ONCE) then return false end
    -- 检查是否有特殊召唤条件限制（有些怪兽用SPSUMMON_CONDITION表示不能通常召唤）
    local sp_eff=c:GetEffectCount(EFFECT_SPSUMMON_CONDITION)
    if sp_eff>0 and not c:IsType(TYPE_NORMAL) then
        -- 进一步检查：若该效果限制了通常召唤，则排除
        -- 通过尝试能否用通常召唤方式处理来判断
        if not c:IsSummonable(true,nil) then return false end
    end
    return true
end

-- ① 操作：根据保存的种族/属性进行精确检索
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local race = c:GetFlagEffectLabel(id+100)
    local att = c:GetFlagEffectLabel(id+200)
    if not race or not att then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,race,att)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- ② 战斗破坏耐性
function s.indval(e,re,r,rp)
    return bit.band(r,REASON_BATTLE)~=0
end