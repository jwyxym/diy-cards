-- 白鸟绘卷——化龙志
local s,id,o=GetID()
function s.initial_effect(c)
    --activate
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_END_PHASE)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
    --atkup
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e2:SetCode(EFFECT_UPDATE_ATTACK)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WYRM))
    e2:SetValue(250)
    c:RegisterEffect(e2)
    --immune
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetCode(EFFECT_IMMUNE_EFFECT)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(s.efilter)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WYRM))
    e3:SetLabelObject(e0)
    c:RegisterEffect(e3)
    --destroy replace
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_FZONE+LOCATION_GRAVE+LOCATION_HAND)
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)
end
function s.setfilter(c)
    return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xe91) and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil)
    if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
        and g:GetCount()>=1 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,nil)
    if g:GetCount()>0 and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local sg=g:Select(tp,1,1,nil)
        local sc=sg:GetFirst()
        if sc then
            Duel.MoveToField(sc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
        end
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1,0)
        e1:SetTarget(s.splimit)
        e1:SetReset(RESET_PHASE+PHASE_END,2)
        Duel.RegisterEffect(e1,tp)
    end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
    -- 不是通常怪兽且不是「画龙」怪兽的场合不能从手卡·卡组特殊召唤
    return not c:IsType(TYPE_NORMAL) and not c:IsSetCard(0xe91) and c:IsLocation(LOCATION_DECK+LOCATION_HAND)
end
function s.efilter(e,te)
    return te:GetOwner():GetAttack()<e:GetHandler():GetAttack() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated() 
end
function s.repfilter(c,tp)
    return c:IsFaceup() and (c:IsType(TYPE_FIELD) or c:IsRace(RACE_WYRM)) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp)
        and not e:GetHandler():IsStatus(STATUS_DESTROY_CONFIRMED) end
    return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.repval(e,c)
    return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end