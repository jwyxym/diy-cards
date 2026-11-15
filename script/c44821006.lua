-- Rose
-- ID: 44821006
-- 记述「Roselia」(44821000)
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,44821000)  -- 此卡记述「Roselia」
    -- ① 场上·墓地的这张卡的种族当作植物族使用
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
    e1:SetCode(EFFECT_CHANGE_RACE)
    e1:SetValue(RACE_PLANT)
    c:RegisterEffect(e1)

    -- ② 把这张卡从手卡丢弃才能发动，从卡组把1张「Roselia」在自己的场地区域表侧表示放置
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_HAND)
    e2:SetCountLimit(1,id)
    e2:SetCost(s.setcost)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)

    -- ③ 这张卡在墓地存在，自己把植物族融合怪兽融合召唤的场合才能发动，这张卡特殊召唤
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id+1000)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
end

-- ② cost：把这张卡从手卡丢弃
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsDiscardable() end
    Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end

-- ② 目标
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end

-- ② 放置对象：「Roselia」(44821000)
function s.setfilter(c)
    return c:IsCode(44821000) and not c:IsForbidden()
end

-- ② 操作：从卡组把「Roselia」表侧表示放置到场地区域（自动覆盖旧场地）
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
    end
end

-- ③ 条件：自己把植物族融合怪兽融合召唤成功
function s.spfilter(c,tp)
    return c:IsType(TYPE_FUSION) and c:IsRace(RACE_PLANT)
        and c:IsControler(tp) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spfilter,1,nil,tp)
end

-- ③ 目标：自身从墓地特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- ③ 操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end