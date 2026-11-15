local s,id=GetID()
local TOKEN_SKULL=65200900
local TOKEN_BAT=65200902
local TOKEN_GHOST=65200903
local id_toki=65200090

function s.initial_effect(c)
    aux.AddCodeList(c, id_toki)

    -- 选项1：生衍生物
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.cond1)
    e1:SetTarget(s.tgtg1)
    e1:SetOperation(s.tgop1)
    c:RegisterEffect(e1)

    -- 选项2：解放检索
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_ACTIVATE)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetCountLimit(1,id)
    e2:SetCondition(s.cond2)
    e2:SetTarget(s.tgtg2)
    e2:SetOperation(s.tgop2)
    c:RegisterEffect(e2)

    -- 被除外回收
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,2))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCode(EVENT_REMOVE)
    e3:SetCountLimit(1,id+3)
    e3:SetTarget(s.remtg)
    e3:SetOperation(s.remop)
    c:RegisterEffect(e3)
end

-- 选项1的独立次数限制
function s.cond1(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id+1)==0
end
-- 选项2的独立次数限制
function s.cond2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id+2)==0
end

function s.tgtg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
end

function s.tgop1(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return not c:IsRace(RACE_ZOMBIE) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
    if ft>0 and Duel.SelectYesNo(tp, aux.Stringid(id,4)) then
        local token=Duel.CreateToken(tp,TOKEN_SKULL)
        Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
        s.register_token_effect(token, e:GetHandler())
        ft=ft-1
    end
    if ft>0 and Duel.SelectYesNo(tp, aux.Stringid(id,5)) then
        local token=Duel.CreateToken(tp,TOKEN_BAT)
        Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
        s.register_token_effect(token, e:GetHandler())
        ft=ft-1
    end
    if ft>0 and Duel.SelectYesNo(tp, aux.Stringid(id,6)) then
        local token=Duel.CreateToken(tp,TOKEN_GHOST)
        Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
        s.register_token_effect(token, e:GetHandler())
        ft=ft-1
    end
    Duel.SpecialSummonComplete()
end

function s.tgtg2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsRace, RACE_ZOMBIE), tp, LOCATION_HAND+LOCATION_MZONE, 0, 1, nil) end
end

function s.tgop2(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE+PHASE_END,0,1)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetTargetRange(1,0)
    e1:SetTarget(function(_,c) return not c:IsRace(RACE_ZOMBIE) end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    local g=Duel.SelectMatchingCard(tp, aux.FilterBoolFunction(Card.IsRace, RACE_ZOMBIE), tp, LOCATION_HAND+LOCATION_MZONE, 0, 1, 1, nil)
    local code = g:GetFirst():GetCode()
    Duel.Release(g, REASON_COST)
    
    local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp,code)
    if #sg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tg=sg:Select(tp,1,1,nil)
        Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
    end
end

function s.register_token_effect(tc, source)
    local e1=Effect.CreateEffect(source)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE+PHASE_END)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetLabelObject(tc)
    e1:SetCountLimit(1)
    e1:SetCondition(function(e,tp) return Duel.GetTurnPlayer()==tp end)
    e1:SetOperation(function(e,tp)
        local token=e:GetLabelObject()
        if token:IsLocation(LOCATION_MZONE) then Duel.Destroy(token,REASON_EFFECT) end
    end)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1, source:GetControler())

    local e2=Effect.CreateEffect(source)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_MATERIAL_LIMIT)
    e2:SetValue(function(e,c) return c:IsType(TYPE_LINK) end)
    e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    tc:RegisterEffect(e2)
end

function s.spfilter(c,e,tp,code)
    return (c:IsCode(id_toki) or aux.IsCodeListed(c, id_toki)) and c:IsType(TYPE_MONSTER) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() or c:IsSSetable() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

function s.remop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if c:IsAbleToHand() and (not c:IsSSetable() or Duel.SelectOption(tp,aux.Stringid(id,7),aux.Stringid(id,8))==0) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    else
        Duel.SSet(tp,c)
    end
end