--阿尔戈☆群星-疾风之波吕尼
--字段：阿尔戈☆群星（0x01C1）

local s,id,o=GetID()
local SET_ALGO_STARS=0x01C1

function s.initial_effect(c)
    --超量召唤（常规+叠放）
    aux.AddXyzProcedure(c,nil,4,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)
    c:EnableReviveLimit()
    
    --①：超量召唤成功时，从手卡·卡组·墓地放置1张永续陷阱（表侧表示），对方效果伤害变0
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SSET)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.setcon)
    e1:SetTarget(s.settg1)
    e1:SetOperation(s.setop1)
    c:RegisterEffect(e1)
    
    --②：准备阶段，取除2个素材，从墓地放置最多3张永续陷阱（表侧表示）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_LEAVE_GRAVE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+o)
    e2:SetCost(s.setcost)
    e2:SetTarget(s.settg2)
    e2:SetOperation(s.setop2)
    c:RegisterEffect(e2)
end

--===============================================================================
-- 叠放超量条件
--===============================================================================
function s.ovfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_ALGO_STARS)
end

function s.xyzop(e,tp,chk)
    if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end

--===============================================================================
-- ①效果：条件（超量召唤成功）
--===============================================================================
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

--===============================================================================
-- ①效果：目标（从手卡·卡组·墓地选择1张阿尔戈☆群星永续陷阱）
--===============================================================================
function s.setfilter(c)
    return c:IsSetCard(SET_ALGO_STARS) and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) 
        and c:IsSSetable() and not c:IsForbidden()
end

function s.settg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil)
        return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
    end
    Duel.SetOperationInfo(0,CATEGORY_SSET,nil,1,0,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

--===============================================================================
-- ①效果：处理（表侧表示放置1张永续陷阱 + 对方效果伤害变0）
--===============================================================================
function s.setop1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil)
    if #g==0 then return end
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local sg=g:Select(tp,1,1,nil)
    if #sg>0 then
        local tc=sg:GetFirst()
        -- 从手牌选择时先确认
        if tc:IsLocation(LOCATION_HAND) then
            Duel.ConfirmCards(1-tp,tc)
        end
        -- 表侧表示放置到魔法与陷阱区域
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        -- 从卡组·墓地选择时确认
        if tc:IsLocation(LOCATION_DECK) or tc:IsLocation(LOCATION_GRAVE) then
            Duel.ConfirmCards(1-tp,tc)
        end
    end
    
    -- 对方受到的效果伤害变成0
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_DAMAGE)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(0,1)
    e1:SetValue(s.damval)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.damval(e,re,val,r,rp,ep)
    return 0
end

--===============================================================================
-- ②效果：Cost（取除2个超量素材）
--===============================================================================
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) end
    c:RemoveOverlayCard(tp,2,2,REASON_COST)
end

--===============================================================================
-- ②效果：目标（从墓地选择最多3张阿尔戈☆群星永续陷阱）
--===============================================================================
function s.pfilter(c,tp)
    return c:IsSetCard(SET_ALGO_STARS) and c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS)
        and not c:IsForbidden() and c:CheckUniqueOnField(tp) and c:IsSSetable()
end

function s.settg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
    end
    local g=Duel.GetMatchingGroup(s.pfilter,tp,LOCATION_GRAVE,0,nil,tp)
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end

--===============================================================================
-- ②效果：处理（从墓地表侧表示放置最多3张永续陷阱）
--===============================================================================
function s.setop2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local ct=math.min(Duel.GetLocationCount(tp,LOCATION_SZONE),3)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.pfilter),tp,LOCATION_GRAVE,0,1,ct,nil,tp)
    for tc in aux.Next(g) do
        -- 表侧表示放置到魔法与陷阱区域
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end