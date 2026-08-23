-- 《<梦魇>恋人与节制》
-- 卡号：65200110  连接2  箭头：左上+右下 = 68
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),2,2)

    -- ① 连接召唤成功时，从墓地特召1只不死族怪兽到连接区
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- ② 连接区怪兽攻击力+500
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(s.linked)
    e2:SetValue(500)
    c:RegisterEffect(e2)

    -- ② 连接区怪兽守备力+500
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetTarget(s.linked)
    e3:SetValue(500)
    c:RegisterEffect(e3)

    -- ② 连接区怪兽效果不能发动（磁律机坏骨架）
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_ACTIVATE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(1,1)
    e4:SetValue(s.aclimit)
    c:RegisterEffect(e4)
end

-- ① 条件：连接召唤
function s.spcon(e,tp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ① 墓地过滤
function s.spfilter(c,e,tp,zone)
    return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,zone)
end
-- ① 目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local zone=e:GetHandler():GetLinkedZone(tp)
    if chk==0 then return zone~=0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ① 操作
function s.spop(e,tp)
    local c=e:GetHandler()
    local zone=c:GetLinkedZone(tp)
    if zone==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,zone)
    if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone) end
end

-- ② 判定目标在连接区
function s.linked(e,c)
    return e:GetHandler():GetLinkedGroup():IsContains(c)
end

-- ② 效果不能发动的判定（磁律机坏同款逻辑）
function s.aclimit(e,re,tp)
    local c=e:GetHandler()
    local rc=re:GetHandler()
    if not rc then return false end
    -- 必须是在连接区的怪兽发动的效果
    return c:GetLinkedGroup():IsContains(rc) and re:IsActiveType(TYPE_MONSTER)
end