-- 追逐月光
-- ID: 26051967
-- 通常魔法（无字段）
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCost(s.cost)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- 发动条件：自己主要阶段1开始时，且本回合尚未进行其他动作
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetCurrentPhase()==PHASE_MAIN1 and Duel.GetTurnPlayer()==tp
        and not Duel.CheckPhaseActivity()
end

-- cost：除外一张手卡
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

-- 检索过滤：等级、属性、种族相同
function s.thfilter(c,lv,att,race)
    return c:IsLevel(lv) and c:IsAttribute(att) and c:IsRace(race) and c:IsAbleToHand()
end

-- 额外融合怪兽过滤
function s.fusfilter(c)
    return c:IsType(TYPE_FUSION)
end

-- 过滤出卡组有匹配怪兽的融合怪兽
function s.fuscheck(c,tp)
    local lv=c:GetLevel()
    local att=c:GetAttribute()
    local race=c:GetRace()
    return lv>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,lv,att,race)
end

-- 目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil)
        return g:IsExists(s.fuscheck,1,nil,tp)
    end
    local g=Duel.GetMatchingGroup(s.fusfilter,tp,LOCATION_EXTRA,0,nil)
    g=g:Filter(s.fuscheck,nil,tp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
    local sg=g:Select(tp,1,1,nil)
    local fc=sg:GetFirst()
    e:SetLabelObject(fc)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- 操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local fc=e:GetLabelObject()
    if not fc then return end
    local lv=fc:GetLevel()
    local att=fc:GetAttribute()
    local race=fc:GetRace()

    -- 给对方确认所选的融合怪兽
    Duel.ConfirmCards(1-tp,fc)

    -- 检索
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,lv,att,race)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end

    -- 自肃1：本回合不能通常召唤
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.sumlimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    -- 自肃2：本回合不能盖放怪兽
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_CANNOT_MSET)
    e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e2:SetTargetRange(1,0)
    e2:SetTarget(s.sumlimit)
    e2:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e2,tp)

    -- 自肃3：本回合不是融合怪兽不能从额外卡组特殊召唤
    local e3=Effect.CreateEffect(e:GetHandler())
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetTargetRange(1,0)
    e3:SetTarget(s.splimit)
    e3:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e3,tp)
end

function s.sumlimit(e,c)
    return true
end

function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION)
end