--主观坍缩
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_SUMMON_PROC)
    e1:SetCondition(s.ntcon)
    e1:SetOperation(s.ntop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetOperation(s.sumsuc)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetRange(LOCATION_HAND)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e3:SetCode(EFFECT_ADD_EXTRA_TRIBUTE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetValue(POS_FACEUP_ATTACK)
    c:RegisterEffect(e3)
end
function s.ntcon(e,c,minc)
    if c==nil then return true end
    return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.ntop(e,tp,eg,ep,ev,re,r,rp)
    e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
end
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if e:GetHandler():GetFlagEffect(id)==0 then return end
    local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
    Duel.Destroy(sg,REASON_EFFECT)
end