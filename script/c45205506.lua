--哥布林工程部队 (45205327)
--字段代码: 0x00AC

local s,id=GetID()

function s.initial_effect(c)
    --①效果：被除外时，从卡组除外1只哥布林怪兽，这张卡特殊召唤
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_REMOVE)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)
    
    --②效果：主要阶段，把墓地1张哥布林卡除外，从卡组·除外状态盖放1张哥布林魔陷
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE+CATEGORY_LEAVE_GRAVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END)
    e2:SetCountLimit(1,id+100)
    e2:SetCost(s.setcost)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
end

--①效果：从卡组除外1只哥布林怪兽
function s.rmfilter(c)
    return c:IsSetCard(0x00AC) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    --从卡组除外1只哥布林怪兽
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 then return end
    if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==0 then return end
    --特殊召唤这张卡
    if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

--②效果Cost：把墓地1张哥布林卡除外
function s.costfilter(c)
    return c:IsSetCard(0x00AC) and c:IsAbleToRemoveAsCost()
end

function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end

--②效果目标：从卡组或除外状态选1张哥布林魔陷盖放
function s.setfilter(c)
    return c:IsSetCard(0x00AC) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and (Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
                or Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_REMOVED,0,1,nil))
    end
    Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    
    local g1=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
    local g2=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_REMOVED,0,nil)
    local g=Group.CreateGroup()
    g:Merge(g1)
    g:Merge(g2)
    if #g==0 then return end
    
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local sg=g:Select(tp,1,1,nil)
    if #sg>0 then
        Duel.SSet(tp,sg:GetFirst())
    end
end