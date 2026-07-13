--画龙点睛 (45205331)
--永续陷阱卡

local s,id=GetID()

function s.initial_effect(c)
    --永续陷阱发动
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    
    --①效果：二选一
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    e1:SetHintTiming(0,TIMING_MAIN_END)
    e1:SetCountLimit(1,id)
    -- ★★★ 取对象标签 ★★★
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end

--①效果选项1过滤：龙族·幻龙族·恐龙族·海龙族怪兽
function s.pltg_filter(c)
    return c:IsType(TYPE_MONSTER) and (c:IsRace(RACE_DRAGON) or c:IsRace(RACE_WYRM) or c:IsRace(RACE_DINOSAUR) or c:IsRace(RACE_SEASERPENT))
end

--①效果选项2过滤：魔陷区·灵摆区的怪兽卡
function s.sptg_filter(c,e,tp)
    return c:IsFaceup() and (c:IsLocation(LOCATION_SZONE) or c:IsLocation(LOCATION_PZONE))
        and c:GetOriginalType()&TYPE_MONSTER>0
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_SZONE+LOCATION_PZONE) and s.sptg_filter(chkc,e,tp)
    end
    if chk==0 then
        local b1 = Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.pltg_filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
        local b2 = Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.sptg_filter,tp,0xff,LOCATION_SZONE+LOCATION_PZONE,1,nil,e,tp)
        return b1 or b2
    end
    -- 二选一
    local opts={}
    table.insert(opts, aux.Stringid(id,1))
    local b2 = Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(s.sptg_filter,tp,0xff,LOCATION_SZONE+LOCATION_PZONE,1,nil,e,tp)
    if b2 then
        table.insert(opts, aux.Stringid(id,2))
    end
    local op = 1
    if #opts>1 then
        op = Duel.SelectOption(tp,table.unpack(opts)) + 1
    end
    e:SetLabel(op)
    if op==1 then
        Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
    else
        -- ★★★ 取对象选择 ★★★
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local g=Duel.SelectTarget(tp,s.sptg_filter,tp,0xff,LOCATION_SZONE+LOCATION_PZONE,1,1,nil,e,tp)
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
    end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==1 then
        -- 选项1：从手卡·卡组把1只符合条件的怪兽作为永续魔法卡放置
        if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local g=Duel.SelectMatchingCard(tp,s.pltg_filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            local tc=g:GetFirst()
            Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_CHANGE_TYPE)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
            tc:RegisterEffect(e1)
        end
    else
        -- 选项2：特殊召唤魔陷区·灵摆区的怪兽卡
        local tc=Duel.GetFirstTarget()
        if tc and tc:IsRelateToEffect(e) then
            Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end