-- 极星天 引领之女武神
local s,id=GetID()
function s.initial_effect(c)
    --①效果：主要阶段发动，cost送墓2卡，特殊召唤2只英灵衍生物
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    
    --②效果：墓地除外，从卡组特召极星天怪兽，当作调整
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end

--①效果cost：从手卡·场上把2张卡送去墓地
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,2,e:GetHandler())
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,2,2,e:GetHandler())
    Duel.SendtoGrave(g,REASON_COST)
end

--①效果目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
            and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
            and Duel.IsPlayerCanSpecialSummonMonster(tp,40844553,0,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end

--①效果处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
    if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,40844553,0,TYPES_TOKEN_MONSTER,1000,1000,4,RACE_WARRIOR,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then return end
    
    --特殊召唤2只英灵衍生物
    for i=1,2 do
        local token=Duel.CreateToken(tp,40844553)
        Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
    end
    Duel.SpecialSummonComplete()
    
    --注册场地限制效果，只要衍生物存在就生效
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    e1:SetLabel(id)
    Duel.RegisterEffect(e1,tp)
    
    --注册衍生物离场监测效果
    local e2=Effect.CreateEffect(e:GetHandler())
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_LEAVE_FIELD)
    e2:SetCondition(s.checkcon)
    e2:SetOperation(s.checkop)
    e2:SetReset(RESET_PHASE+PHASE_END)
    e2:SetLabelObject(e1)
    Duel.RegisterEffect(e2,tp)
end

--额外卡组限制：不是同调怪兽不能特殊召唤
function s.splimit(e,c)
    return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end

--检查衍生物是否全部离场
function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(Card.IsCode,1,nil,40844553)
end

--如果衍生物离场，检查是否还有其他衍生物存在
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,40844553)
    if #g==0 then
        --所有衍生物都离场，清除限制效果
        local e1=e:GetLabelObject()
        if e1 then
            e1:Reset()
        end
    end
end

--②效果过滤：极星天怪兽（字段0x3042）
function s.spfilter(c,e,tp)
    return c:IsSetCard(0x3042) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

--②效果目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

--②效果处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        local tc=g:GetFirst()
        if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
            --当作调整使用
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_ADD_TYPE)
            e1:SetValue(TYPE_TUNER)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1,true)
        end
        Duel.SpecialSummonComplete()
    end
end