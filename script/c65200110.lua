-- 《<梦魇>恋人与节制》
-- 卡号：65200110  连接2  箭头：左上+右下 = 68
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),2,2)

    -- ① 连接召唤成功时，从墓地特召1只不死族怪兽。
    --    那之后，这张卡当作永续魔法卡在自己的魔法与陷阱区域放置。
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

    -- ② 作为永续魔法时，自己场上不死族怪兽攻击力上升数量×300
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,0)
    e2:SetTarget(s.atktg)
    e2:SetValue(s.atkval)
    c:RegisterEffect(e2)

    -- ② 守备力上升数量×300
    local e3=e2:Clone()
    e3:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e3)

    -- ② 自己不能在自己的不死族怪兽召唤·特殊召唤时发动效果
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_CANNOT_ACTIVATE)
    e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTargetRange(1,0)
    e4:SetValue(s.aclimit)
    c:RegisterEffect(e4)
end

-- ① 条件：连接召唤
function s.spcon(e,tp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

-- ① 墓地过滤：不死族
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ① 目标：确认墓地有怪且场上有空位
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

-- ① 操作：特召不死族，然后自身变成永续魔法
function s.spop(e,tp)
    local c=e:GetHandler()
    if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
        if #g>0 then
            Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
        end
    end

    -- 那之后，这张卡当作永续魔法卡放置
    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) then
        Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end

-- ② 攻守加成目标：自己场上的不死族怪兽
function s.atktg(e,c)
    return c:IsRace(RACE_ZOMBIE)
end

-- ② 攻守加成数值：自己场上不死族怪兽数量×300
function s.atkval(e,c)
    local g=Duel.GetMatchingGroup(s.zombiefilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
    return #g*300
end
function s.zombiefilter(c)
    return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end

-- ② 封锁条件：自己不死族怪兽召唤/特召成功时发动的效果
function s.aclimit(e,re,tp)
    local code=re:GetCode()
    if code~=EVENT_SUMMON_SUCCESS and code~=EVENT_SPSUMMON_SUCCESS then return false end
    local rc=re:GetHandler()
    return rc and rc:IsControler(tp) and rc:IsRace(RACE_ZOMBIE)
end