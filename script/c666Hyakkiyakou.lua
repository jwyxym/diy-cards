--库「百鬼夜行」
XiaoyeHyakkiyakou={}
xiaoye=XiaoyeHyakkiyakou
LOCATION_ALL=LOCATION_DECK+LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_ONFIELD
--destroy replace
function XiaoyeHyakkiyakou.PendulumRepalce(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_DESTROY_REPLACE)
    e1:SetRange(LOCATION_PZONE)
    e1:SetTarget(XiaoyeHyakkiyakou.PendulumRepalceTarget)
    e1:SetValue(XiaoyeHyakkiyakou.PendulumRepalceVal)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetRange(LOCATION_ONFIELD)
    c:RegisterEffect(e2)
    local e3=e1:Clone()
    e3:SetRange(LOCATION_HAND)
    c:RegisterEffect(e3)
end
function XiaoyeHyakkiyakou.PendulumRepalceTarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return eg:IsExists(XiaoyeHyakkiyakou.PendulumRepalceFilter,1,nil,tp) end
    if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
        Duel.SendtoExtraP(e:GetHandler(),nil,REASON_REPLACE+REASON_EFFECT)
        return true
    end
        return false
end
function XiaoyeHyakkiyakou.PendulumRepalceFilter(c,tp)
    return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsCode(66600001) and c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function XiaoyeHyakkiyakou.PendulumRepalceVal(e,c)
    return XiaoyeHyakkiyakou.PendulumRepalceFilter(c,e:GetHandlerPlayer())
end
--effect and grant
function XiaoyeHyakkiyakou.MonsterEffectAndGrant(c,id,Category,Type,Code,HintTiming,Cost,Condition,Target,Operation,Property)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(Type)
    if Category~=0 then e1:SetCategory(Category) end
    if Code~=0 then e1:SetCode(Code) end
    if HintTiming~=0 then e1:SetHintTiming(0,HintTiming) end
    e1:SetRange(LOCATION_MZONE)
    if Property~=0 then e1:SetProperty(Property) end
    e1:SetCountLimit(1,id)
    if Cost==0 then e1:SetCost(XiaoyeHyakkiyakou.MonsterEffectCost) end
    if Condition~=0 then e1:SetCondition(Condition) end
    e1:SetTarget(Target)
    e1:SetOperation(Operation)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e2:SetRange(LOCATION_SZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetTarget(XiaoyeHyakkiyakou.MonsterEffectGrantTarget)
    e2:SetLabelObject(e1)
    c:RegisterEffect(e2)
end
function XiaoyeHyakkiyakou.MonsterEffectCost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(XiaoyeHyakkiyakou.MonsterEffectCostFilter,tp,LOCATION_MZONE,0,nil,tp)
    if chk==0 then return g:GetCount()>0 end
    if g:GetCount()>1 then g=g:Select(tp,1,1,nil) end
    g:GetFirst():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function XiaoyeHyakkiyakou.MonsterEffectCostFilter(c,tp)
    return c:IsType(TYPE_XYZ) and c:IsCode(66600001) and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
function XiaoyeHyakkiyakou.MonsterEffectGrantTarget(e,c)
    return c:IsType(TYPE_MONSTER) and c:IsCode(66600001) and c:GetEquipGroup():IsContains(e:GetHandler())
end
--SummonLines
function XiaoyeHyakkiyakou.SummonLines(c,SummonStr)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetOperation(XiaoyeHyakkiyakou.SummonLinesOperation(SummonStr))
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)
end
function XiaoyeHyakkiyakou.SummonLinesOperation(SummonStr)
    SummonStr="\n" .. SummonStr
    return  function(e,tp,eg,ep,ev,re,r,rp,chk)
                Debug.Message(SummonStr)
            end
end