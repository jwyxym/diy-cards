local s,id=GetID()

function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddRitualProcGreater(c,s.ritual_filter)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCondition(s.immcon)
    e1:SetValue(s.immval)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.immcon)
    e2:SetValue(aux.tgoval)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCondition(s.immcon)
    e3:SetValue(aux.indoval)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_BATTLE_START)
    e4:SetCondition(s.descon)
    e4:SetTarget(s.destg)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_SINGLE)
    e5:SetCode(EFFECT_EXTRA_ATTACK)
    e5:SetValue(2)
    c:RegisterEffect(e5)
end

function s.ritual_filter(c)
    return c:IsRace(RACE_ZOMBIE)
end

function s.immcon(e)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.immval(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.descon(e,tp)
    local c=e:GetHandler()
    local tc=c:GetBattleTarget()
    return tc and tc:IsControler(1-tp) and tc:IsFaceup()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local tc=e:GetHandler():GetBattleTarget()
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetHandler():GetBattleTarget()
    if tc and tc:IsRelateToBattle() then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end