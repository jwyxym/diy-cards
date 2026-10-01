local s,id=GetID()
local NM=0x32a

if not _G.NM_DAMAGE_65200260 then
    _G.NM_DAMAGE_65200260 = true
    local ge=Effect.GlobalEffect()
    ge:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge:SetCode(EVENT_DAMAGE)
    ge:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        Duel.RegisterFlagEffect(ep, 65200260, RESET_PHASE+PHASE_END, 0, 1)
    end)
    Duel.RegisterEffect(ge, 0)
end

function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddFusionProcFun2(c,s.matfilter1,s.matfilter2,true)

    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD)
    e0:SetCode(EFFECT_SPSUMMON_PROC)
    e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e0:SetRange(LOCATION_EXTRA)
    e0:SetCondition(s.spcon)
    e0:SetOperation(s.spop)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg)
    e1:SetOperation(s.op)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,3))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_DAMAGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCondition(s.damcon)
    e2:SetOperation(s.damop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetValue(s.immval)
    c:RegisterEffect(e3)
end

function s.matfilter1(c)
    return c:IsSetCard(NM) and c:IsType(TYPE_MONSTER)
end
function s.matfilter2(c)
    return c:IsSetCard(NM) and c:IsType(TYPE_MONSTER)
end

function s.spfilter1(c)
    return c:IsSetCard(NM) and c:IsLevelAbove(6)
end
function s.spfilter2(c)
    return c:IsSetCard(NM) and c:IsLevelBelow(4)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    local g1=Duel.GetMatchingGroup(s.spfilter1,tp,LOCATION_MZONE,0,nil)
    local g2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_MZONE,0,nil)
    local tc1=g1:GetFirst()
    while tc1 do
        local tc2=g2:GetFirst()
        while tc2 do
            if math.abs(tc1:GetLevel()-tc2:GetLevel())<=2 then return true end
            tc2=g2:GetNext()
        end
        tc1=g1:GetNext()
    end
    return false
end
function s.spfilter2b(c,tc1)
    return s.spfilter2(c) and math.abs(c:GetLevel()-tc1:GetLevel())<=2
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_MZONE,0,1,1,nil)
    if #g1==0 then return end
    local tc1=g1:GetFirst()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g2=Duel.SelectMatchingCard(tp,s.spfilter2b,tp,LOCATION_MZONE,0,1,1,nil,tc1)
    if #g2==0 then return end
    g1:Merge(g2)
    Duel.SendtoGrave(g1,REASON_COST)
end

function s.desfilter(c,atk)
    return c:IsFaceup() and c:GetDefense()<atk
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local c=e:GetHandler()
    local atk=c:GetAttack()
    local b1=Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,atk)
    if b1 then
        e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)))
    else
        e:SetLabel(1)
    end
    if e:GetLabel()==0 then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
    else
        Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,800)
    end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if e:GetLabel()==0 then
        local atk=c:GetAttack()
        local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,atk)
        if #g>0 then
            Duel.HintSelection(g)
            Duel.Destroy(g,REASON_EFFECT)
        end
    else
        Duel.Damage(tp,800,REASON_EFFECT)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DIRECT_ATTACK)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e1)
    end
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    return ep==tp
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(ev)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    c:RegisterEffect(e1)
end

function s.immval(e,te)
    local c=e:GetHandler()
    local tp=c:GetControler()
    if Duel.GetFlagEffect(tp, 65200260)<4 then return false end
    return te:GetOwnerPlayer()~=tp
end