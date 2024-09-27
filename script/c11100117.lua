lion_dance={}
function lion_dance.splimit(c,tp)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function (e,tc)
        return not tc:IsRace(RACE_BEAST+RACE_WARRIOR+RACE_SPELLCASTER)
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end
function lion_dance.ass_synchro_material(c,m,f,tg,op,category)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(m,1))
    if aux.GetValueType(category)=="number" then e1:SetCategory(category) end
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_BE_MATERIAL)
    e1:SetCountLimit(1,m+1)
    e1:SetCondition(lion_dance.ass_synchro_material_con(f))
    if aux.GetValueType(tg)=="function" then e1:SetTarget(tg) end
    if aux.GetValueType(op)=="function" then e1:SetOperation(op) end
    c:RegisterEffect(e1)
end
function lion_dance.ass_synchro_material_con(f)
    return function(e,tp,eg,ep,ev,re,r,rp)
        local c=e:GetHandler()
        return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO and (aux.GetValueType(f)~="function" or f(c:GetReasonCard()))
    end
end