local s,id=GetID()
local TOKEN_ZOMBIE=65200901
local id_toki=65200090

function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddLinkProcedure(c, aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE), 2, 99, s.lcheck)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.tkcon)
    e1:SetTarget(s.tktg)
    e1:SetOperation(s.tkop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.negcon)
    e2:SetCost(s.negcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetTargetRange(0,LOCATION_MZONE)
    e3:SetCondition(s.atkcon)
    e3:SetValue(s.atkval)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(s.protg)
    e4:SetValue(1)
    c:RegisterEffect(e4)
end

function s.lcheck(g,lc,tp)
    return g:IsExists(function(c) return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) end, 1, nil)
end

function s.tkcon(e,tp) return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ZOMBIE,0,TYPES_TOKEN,2000,2000,3,RACE_ZOMBIE,ATTRIBUTE_DARK) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local zone=c:GetLinkedZone(tp)
    local avail={}
    for i=0,6 do
        local z=1<<i
        if zone&z~=0 and Duel.CheckLocation(tp,LOCATION_MZONE,i) then table.insert(avail,z) end
    end
    if #avail==0 then return end
    local ct=math.min(3,#avail)
    for i=1,ct do
        if Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ZOMBIE,0,TYPES_TOKEN,2000,2000,3,RACE_ZOMBIE,ATTRIBUTE_DARK) then
            local token=Duel.CreateToken(tp,TOKEN_ZOMBIE)
            Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP,avail[i])
        end
    end
    Duel.SpecialSummonComplete()

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c,sump,sumtype) return sumtype==SUMMON_TYPE_LINK and c:IsLinkAbove(2) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local rc=re:GetHandler()
    return rc~=c and Duel.IsChainNegatable(ev) and rp~=tp
end
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckReleaseGroup(tp,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),1,e:GetHandler()) end
    local g=Duel.SelectReleaseGroup(tp,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),1,1,e:GetHandler())
    Duel.Release(g,REASON_COST)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateEffect(ev) then
        local ct=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_TOKEN)
        if ct>0 then Duel.Damage(1-tp,ct*350,REASON_EFFECT) end
    end
end

function s.atkcon(e)
    return Duel.IsExistingMatchingCard(Card.IsType,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,TYPE_TOKEN)
end
function s.atkval(e,c)
    return c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_EFFECT)
end
function s.protg(e,c)
    return c:IsControler(e:GetHandlerPlayer()) and (c:IsCode(id_toki) or aux.IsCodeListed(c, id_toki))
end