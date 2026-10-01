local s,id=GetID()
local TOKEN_ID=65200900

function s.initial_effect(c)
    aux.AddCodeList(c, 65200270)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DECKDES)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.tkcon)
    e2:SetTarget(s.tktg)
    e2:SetOperation(s.tkop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_UPDATE_ATTACK)
    e3:SetValue(800)
    e3:SetCondition(s.atkcon)
    c:RegisterEffect(e3)
    local e4=e3:Clone()
    e4:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e4)
end

function s.tgfilter(c)
    return c:IsFaceup() and c:IsReleasable()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
            and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.op1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end
    local atk=tc:GetAttack()
    if not c:IsRelateToEffect(e) then return end

    if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
        if atk>0 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(atk)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            c:RegisterEffect(e1)
        end
        if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) then
            Duel.BreakEffect()
            Duel.Destroy(tc,REASON_EFFECT)
        end
    end
end

function s.tkcon(e,tp)
    local c=e:GetHandler()
    return c:IsFaceup() and c:GetAttack()~=c:GetBaseAttack()
end

function s.gravefilter(c)
    return c:IsRace(RACE_ZOMBIE) and not c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
end

function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
            and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ID,0,TYPES_TOKEN,1000,1000,1,RACE_ZOMBIE,ATTRIBUTE_DARK)
            and Duel.IsExistingMatchingCard(s.gravefilter,tp,LOCATION_DECK,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end

function s.tkop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    if not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ID,0,TYPES_TOKEN,1000,1000,1,RACE_ZOMBIE,ATTRIBUTE_DARK) then return end

    local token=Duel.CreateToken(tp,TOKEN_ID)
    if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)==0 then return end

    if Duel.IsExistingMatchingCard(s.gravefilter,tp,LOCATION_DECK,0,1,nil) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
        local g=Duel.SelectMatchingCard(tp,s.gravefilter,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.SendtoGrave(g,REASON_EFFECT)
        end
    end
end

function s.atkcon(e)
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsFaceup() and c:IsCode(65200270)
    end,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end