-- 拜伦的证明
-- ID: 26051969
-- 通常陷阱
local s,id=GetID()
function s.initial_effect(c)
    -- 通常陷阱发动（场上）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- 从手卡发动
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e2:SetCost(s.handcost)
    c:RegisterEffect(e2)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp or not re:IsActiveType(TYPE_MONSTER) then return false end
    -- 从手卡发动时，额外要求对方场上有卡
    if e:GetHandler():IsLocation(LOCATION_HAND) then
        return Duel.IsExistingMatchingCard(s.truefilter,tp,0,LOCATION_ONFIELD,1,nil)
    end
    return true
end

function s.truefilter(c)
    return true
end

function s.handcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,math.floor(Duel.GetLP(tp)/2)) end
    Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local rc=re:GetHandler()
    if chk==0 then return rc:IsRelateToEffect(re) and rc:IsAbleToRemove() end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,0,0)
    -- 标记是否从手卡发动
    if e:GetHandler():IsLocation(LOCATION_HAND) then
        e:SetLabel(1)
    else
        e:SetLabel(0)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    if Duel.NegateActivation(ev) then
        if rc:IsRelateToEffect(re) and rc:IsAbleToRemove() then
            Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
        end
        -- 从手卡发动的场合，让对手选择是否特召同名怪兽
        if e:GetLabel()==1 then
            local code=rc:GetCode()
            if Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
                local zones=LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE
                local tg=Duel.GetMatchingGroup(function(c)
                    return c:GetCode()==code and c:IsCanBeSpecialSummoned(e,0,1-tp,false,false)
                end,1-tp,zones,0,nil)
                if #tg>0 then
                    Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
                    local sg=tg:Select(1-tp,1,1,nil)
                    Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)
                end
            end
        end
    end
end