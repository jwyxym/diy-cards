-- 无垠轨途 乘员档案
-- ID: 26051937
-- 字段: 0x903
local s,id=GetID()
local DISTANT_VIEW_ID = 26051938  -- 空都远眺

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.trainfilter(c)
    return c:IsCode(26051926)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
        and Duel.IsExistingMatchingCard(s.trainfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
    local c=e:GetHandler()

    -- 自肃（与菲妮雅/霖相同写法）
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    -- 选择卡组·墓地1只「无垠轨途」怪兽
    local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
    if #sg>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
        local tc=sg:Select(tp,1,1,nil):GetFirst()
        local op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
        if op==0 then
            Duel.SendtoHand(tc,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,tc)
        else
            if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
                Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
            else
                Duel.SendtoHand(tc,nil,REASON_EFFECT)
                Duel.ConfirmCards(1-tp,tc)
            end
        end
    end

    -- 只有列车长时，可选放空都远眺
    local mg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    if #mg==1 and mg:IsExists(s.trainfilter,1,nil)
        and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local dg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
        if #dg>0 then
            Duel.MoveToField(dg:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        end
    end
end

function s.filter(c)
    return c:IsSetCard(0x903) and c:IsType(TYPE_MONSTER)
end
function s.setfilter(c)
    return c:IsCode(DISTANT_VIEW_ID) and not c:IsForbidden()
end
function s.splimit(e,c)
    return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x903)
end