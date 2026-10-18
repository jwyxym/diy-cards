local s,id=GetID()
local HOLY=0x474

function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddSynchroProcedure(c, aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER), aux.NonTuner(nil), 1, 99)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SSET)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.cond1a)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_SSET)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_DECK)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.cond1b)
    e2:SetTarget(s.tg1)
    e2:SetOperation(s.op1)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_DISABLE+CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetHintTiming(0,TIMING_MAIN_END)
    e3:SetCountLimit(1,id+100)
    e3:SetCondition(s.cond2)
    e3:SetTarget(s.tg2)
    e3:SetOperation(s.op2)
    c:RegisterEffect(e3)
end

function s.cond1a(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.cond1b(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.filter1b,1,nil)
end
function s.filter1b(c)
    return c:IsAttribute(ATTRIBUTE_DARK) and c:IsLocation(LOCATION_EXTRA)
end

function s.filter1(c)
    return c:IsSetCard(HOLY) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil) end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    if opt==0 then
        Duel.SSet(tp,tc)
    else
        Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
    end
end

function s.cond2(e,tp)
    return Duel.IsMainPhase()
end

function s.target_filter(c,tp)
    if not (c:IsFaceup() and c:IsControler(tp) and c:IsAbleToGrave()) then return false end
    local kind = c:GetOriginalType()
    local check_kind = 0
    if kind & TYPE_MONSTER > 0 then check_kind = TYPE_MONSTER
    elseif kind & TYPE_SPELL > 0 then check_kind = TYPE_SPELL
    elseif kind & TYPE_TRAP > 0 then check_kind = TYPE_TRAP
    else return false end
    return Duel.IsExistingMatchingCard(function(tc)
        return tc ~= c and tc:IsFaceup() and (tc:GetOriginalType() & check_kind) > 0
    end, 0, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil)
end

function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.target_filter(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(s.target_filter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectTarget(tp,s.target_filter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
    local tc=g:GetFirst()
    local kind=tc:GetOriginalType()
    if kind & TYPE_MONSTER > 0 then e:SetLabel(TYPE_MONSTER)
    elseif kind & TYPE_SPELL > 0 then e:SetLabel(TYPE_SPELL)
    elseif kind & TYPE_TRAP > 0 then e:SetLabel(TYPE_TRAP) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
end

function s.op2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local kind=e:GetLabel()

    Duel.SendtoGrave(tc,REASON_EFFECT)

    local g=Duel.GetMatchingGroup(function(cc)
        return cc:IsFaceup() and (cc:GetOriginalType() & kind) > 0
    end, 0, LOCATION_ONFIELD, LOCATION_ONFIELD, nil)
    if g:GetCount()>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)
        local dc=g:Select(tp,1,1,nil):GetFirst()
        if dc then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            dc:RegisterEffect(e1)
            local e2=e1:Clone()
            e2:SetCode(EFFECT_DISABLE_EFFECT)
            dc:RegisterEffect(e2)
        end
    end

    if c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE) then
        Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_EFFECT)
    end
end