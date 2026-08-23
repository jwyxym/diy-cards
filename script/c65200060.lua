-- 《<梦魇>猫咪走绳师》
-- 卡号：65200060  暗/不死族/5星/调整/效果 2000/2500
local s,id=GetID()
local TOKEN_SKULL=65200900

function s.initial_effect(c)
    -- ① 双方主要阶段发动
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)

    -- ② 召唤·特召时生成最多2只骷髅士兵衍生物
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.tktg)
    e2:SetOperation(s.tkop)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end

-- ① 条件：主要阶段
function s.condition(e,tp)
    return Duel.IsMainPhase()
end

-- ① Cost：解放自己场上1只怪兽
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.CheckReleaseGroup(tp,nil,1,nil)
    end
    local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
    Duel.Release(g,REASON_COST)
end

-- ① Target
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- ① Operation（先特召，后可选破坏）
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
    -- 可选破坏对方守备1500以下怪兽
    local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
    if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local sg=dg:Select(tp,1,1,nil)
        if #sg>0 then
            Duel.HintSelection(sg)
            Duel.Destroy(sg,REASON_EFFECT)
        end
    end
end
function s.desfilter(c)
    return c:IsFaceup() and c:IsDefenseBelow(1500)
end

-- ② 衍生物 Target
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SKULL,0,TYPES_TOKEN,1000,1000,1,RACE_ZOMBIE,ATTRIBUTE_DARK) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end

-- ② 衍生物 Operation
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    local max=math.min(2,Duel.GetLocationCount(tp,LOCATION_MZONE))
    if max<=0 then return end
    local num=1
    if max>1 then num=Duel.AnnounceNumber(tp,1,2) end
    for i=1,num do
        if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then break end
        if Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_SKULL,0,TYPES_TOKEN,1000,1000,1,RACE_ZOMBIE,ATTRIBUTE_DARK) then
            local token=Duel.CreateToken(tp,TOKEN_SKULL)
            Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
        end
    end
    Duel.SpecialSummonComplete()
end