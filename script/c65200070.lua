local s,id=GetID()
local TOKEN_BAT=65200902
local TOKEN_ZOMBIE=65200901
local TOKEN_GHOST=65200903
local id_toki=65200090

function s.initial_effect(c)
    aux.AddCodeList(c, id_toki)

    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.tgtg)
    e1:SetOperation(s.tgop)
    c:RegisterEffect(e1)

    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_BATTLE_DAMAGE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetCondition(s.reccon)
    e2:SetOperation(s.recop)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetRange(LOCATION_FZONE)
    e3:SetCondition(s.zcon)
    e3:SetTarget(s.ztg)
    e3:SetOperation(s.zop)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_DIRECT_ATTACK)
    e4:SetRange(LOCATION_FZONE)
    e4:SetTargetRange(LOCATION_MZONE,0)
    e4:SetTarget(function(e,c) return c:IsCode(TOKEN_GHOST) and c:IsFaceup() end)
    c:RegisterEffect(e4)

    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD)
    e5:SetCode(EFFECT_CHANGE_RACE)
    e5:SetRange(LOCATION_FZONE)
    e5:SetTargetRange(LOCATION_MZONE,0)
    e5:SetTarget(function(e,c) return c:IsType(TYPE_TOKEN) and not c:IsCode(TOKEN_BAT) and not c:IsCode(TOKEN_ZOMBIE) and not c:IsCode(TOKEN_GHOST) end)
    e5:SetValue(RACE_ZOMBIE)
    c:RegisterEffect(e5)

    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,3))
    e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e6:SetCode(EVENT_RELEASE)
    e6:SetProperty(EFFECT_FLAG_DELAY)
    e6:SetRange(LOCATION_FZONE)
    e6:SetCountLimit(1,id+1)
    e6:SetCondition(s.tokicon)
    e6:SetTarget(s.tokitg)
    e6:SetOperation(s.tokiop)
    c:RegisterEffect(e6)
end

function s.tgfilter(c,tp)
    local has_toki = Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,id_toki)
    if not has_toki then
        return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave() and (c:IsCode(id_toki) or aux.IsCodeListed(c, id_toki))
    end
    return c:IsRace(RACE_ZOMBIE) and c:IsAbleToGrave()
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
end

-- ★ 核心修复：用 GetAttacker 直接抓取攻击怪兽，无视 eg 丢失
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
    if ep==1-tp and bit.band(r,REASON_BATTLE)~=0 then
        local tc = Duel.GetAttacker()
        if not tc then tc = eg:GetFirst() end
        return tc and tc:IsCode(TOKEN_BAT) and tc:IsControler(tp)
    end
    return false
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Recover(tp,ev,REASON_EFFECT)
end

function s.zcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(function(c) 
        return c:IsCode(TOKEN_ZOMBIE) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) 
    end, 1, nil)
end
function s.ztg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_ZOMBIE,0,TYPES_TOKEN,1000,1000,3,RACE_ZOMBIE,ATTRIBUTE_DARK) end
    Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
end
function s.zop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local token=Duel.CreateToken(tp,TOKEN_ZOMBIE)
    Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    token:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    token:RegisterEffect(e2)
    Duel.SpecialSummonComplete()
end

function s.tokicon(e,tp,eg,ep,ev,re,r,rp)
    if eg:IsExists(function(c) return c:IsType(TYPE_TOKEN) and c:IsPreviousControler(tp) end, 1, nil) then
        return Duel.GetMatchingGroupCount(function(c) return c:IsFaceup() and c:IsType(TYPE_EFFECT) end, tp, LOCATION_MZONE, 0, nil) == 0
    end
    return false
end
function s.tokitg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,id_toki) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.tokiop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK,0,1,1,nil,id_toki)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end