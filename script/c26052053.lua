-- 穚镰鸦姬 冥鸦引殁
-- ID: 26052053
-- 字段：穚镰鸦姬 0x914
local s,id=GetID()
local RACE_BIRD = 512

function s.is_bird(c)
    local r=c:GetRace()
    return (r & RACE_BIRD)~=0 or r==1029
end

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsFaceup() and c:IsSetCard(0x914) and c:IsType(TYPE_MONSTER)
    end,tp,LOCATION_MZONE,0,1,nil)
end

function s.tgfilter(c)
    return c:IsSetCard(0x914) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil)
    if #g==0 then return end
    Duel.SendtoGrave(g,REASON_EFFECT)
    -- 对方有怪兽时可以再送1只
    if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) then
        if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local g2=Duel.SelectMatchingCard(tp,function(c) return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave() end,tp,LOCATION_EXTRA,0,1,1,nil)
            if #g2>0 then Duel.SendtoGrave(g2,REASON_EFFECT) end
        end
    end
    -- 自肃
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
    if not c then return false end
    if c:IsLocation(LOCATION_EXTRA) then return true end
    return not s.is_bird(c)
end