-- 温暖的时间 长崎爽世
-- ID: 26062903
-- 记述「春日影」(26062911)
-- 「丰川祥子」字段 0xb10
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)

    -- ① 召唤·特殊召唤成功时发动
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetCost(s.cost)
    e1:SetTarget(s.tg1)
    e1:SetOperation(s.op1)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e2)

    -- ② 从场上以外送墓时发动
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOFIELD)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id+1)
    e3:SetCondition(s.condition2)
    e3:SetTarget(s.target2)
    e3:SetOperation(s.operation2)
    c:RegisterEffect(e3)
end

-- ① cost：从卡组送墓1只魔法师族以外的记述怪兽
function s.costfilter(c)
    return aux.IsCodeListed(c,26062911) and c:IsType(TYPE_MONSTER)
        and not c:IsRace(RACE_SPELLCASTER) and c:IsAbleToGrave()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
    Duel.SendtoGrave(g,REASON_COST)
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
    -- 自肃：本回合不能发动「春日影」以外的场地魔法
    local e_limit=Effect.CreateEffect(e:GetHandler())
    e_limit:SetType(EFFECT_TYPE_FIELD)
    e_limit:SetCode(EFFECT_CANNOT_ACTIVATE)
    e_limit:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e_limit:SetTargetRange(1,0)
    e_limit:SetValue(s.aclimit)
    e_limit:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e_limit,tp)

    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
    -- 等级上升或下降2
    local op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
    local lv_change = (op==0) and 2 or -2
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_LEVEL)
    e1:SetValue(lv_change)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    c:RegisterEffect(e1)
    -- 墓地有「丰川祥子」怪兽时可选变协调
    if Duel.IsExistingMatchingCard(aux.FilterBoolFunction(Card.IsSetCard,0xb10),tp,LOCATION_GRAVE,0,1,nil)
        and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_ADD_TYPE)
        e2:SetValue(TYPE_TUNER)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        c:RegisterEffect(e2)
    end
end

-- 不能发动「春日影」以外的场地魔法
function s.aclimit(e,re,tp)
    return re:IsActiveType(TYPE_FIELD) and not re:GetHandler():IsCode(26062911)
end

-- ② 条件：从场上以外送去墓地
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
    return not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ② 盖放对象：记述「春日影」的永续魔法·永续陷阱
function s.filter2(c)
    return aux.IsCodeListed(c,26062911) and c:IsType(TYPE_CONTINUOUS)
        and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsSSetable()
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil) end
end
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g:GetFirst())
    end
end