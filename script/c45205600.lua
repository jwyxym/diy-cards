--战华之花-月蝉
--卡密ID: 45205602
--字段代码: 0x0137

local s,id=GetID()

function s.initial_effect(c)
    --①效果
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id+100)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    
    --②效果
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMING_MAIN_END)
    e2:SetCountLimit(1,id+200)
    e2:SetCost(s.cost)
    e2:SetTarget(s.target)
    e2:SetOperation(s.activate)
    c:RegisterEffect(e2)
end

--①效果条件
function s.filter(c)
    return c:IsFaceup() and c:IsSetCard(0x0137) and c:GetLevel()>=6
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
    end
end

--主要怪兽区过滤
function s.zonefilter(c)
    return c:GetSequence()<5
end

--COST过滤
function s.costfilter(c)
    return c:IsAbleToGraveAsCost() and c:GetSequence()<5
end

--②效果Cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local zone=0x7f
    local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
    if chk==0 then
        if ct>0 then
            return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler())
        else
            return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
        end
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    if ct>0 then
        local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
        Duel.SendtoGrave(g,REASON_COST)
    else
        local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
        Duel.SendtoGrave(g,REASON_COST)
    end
end

--②效果选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local b1 = Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
    local b2 = Duel.IsExistingMatchingCard(s.ctrlfilter,tp,0,LOCATION_MZONE,1,nil)
    if chk==0 then return b1 or b2 end
    local opts = {}
    local op1, op2
    if b1 then
        op1=#opts+1
        table.insert(opts, {true, aux.Stringid(id,2)})
    end
    if b2 then
        op2=#opts+1
        table.insert(opts, {true, aux.Stringid(id,3)})
    end
    local op=aux.SelectFromOptions(tp, table.unpack(opts))
    
    if op==op1 then
        e:SetLabel(1)
        e:SetCategory(CATEGORY_SPECIAL_SUMMON)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
    elseif op==op2 then
        e:SetLabel(2)
        e:SetCategory(CATEGORY_CONTROL)
        Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
    end
end

--②效果处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    
    if op==1 then
        local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
        if #g==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local sc=g:Select(tp,1,1,nil):GetFirst()
        if sc then
            Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
        end
    else
        local g=Duel.GetMatchingGroup(s.ctrlfilter,tp,0,LOCATION_MZONE,nil)
        if #g==0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
        local tc=g:Select(tp,1,1,nil):GetFirst()
        if tc then
            Duel.GetControl(tc,tp)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_ADD_SETCODE)
            e1:SetValue(0x0137)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD)
            tc:RegisterEffect(e1)
        end
    end
end

function s.spfilter(c,e,tp)
    return c:IsSetCard(0x0137) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.ctrlfilter(c)
    return c:IsFaceup() and c:GetSequence()<5
end