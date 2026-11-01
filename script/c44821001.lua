-- 歌姬的觉悟 凑友希那
-- ID: 44830000
-- 「Roselia」卡密：44821000
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,44821000)

    -- ① 自己场上没有非「Roselia」记述的表侧怪兽时，从手卡特殊召唤（1回合1次）
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetCondition(s.spcon)
    c:RegisterEffect(e1)

    -- ② 召唤·特殊召唤成功时，放置「Roselia」或永续魔陷
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_TOFIELD)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id+1000)
    e2:SetTarget(s.target)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    c:RegisterEffect(e3)
end

-- ① 条件：自己场上没有非「Roselia」记述的表侧表示怪兽
function s.spfilter(c)
    return c:IsFaceup() and not aux.IsCodeListed(c,44821000)
end
function s.spcon(e,c)
    if c==nil then return true end
    local tp=c:GetControler()
    return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- ② 可放置「Roselia」到场地
function s.setfilter1(c)
    return c:IsCode(44821000) and not c:IsForbidden()
end
-- ② 可放置记述「Roselia」的永续魔法·永续陷阱
function s.setfilter2(c)
    return aux.IsCodeListed(c,44821000) and c:IsType(TYPE_CONTINUOUS)
        and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
        and not c:IsForbidden()
end

-- ② 目标：检查是否存在任一可放置的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local can_field = Duel.IsExistingMatchingCard(s.setfilter1,tp,LOCATION_DECK,0,1,nil)
        local has_roselia = Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,44821000)
        local can_cont = has_roselia and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.setfilter2,tp,LOCATION_DECK,0,1,nil)
        return can_field or can_cont
    end
    Duel.SetOperationInfo(0,CATEGORY_TOFIELD,nil,1,tp,LOCATION_DECK)
end

-- ② 操作
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local can_field = Duel.IsExistingMatchingCard(s.setfilter1,tp,LOCATION_DECK,0,1,nil)
    local has_roselia = Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,44821000)
    local can_cont = has_roselia and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
        and Duel.IsExistingMatchingCard(s.setfilter2,tp,LOCATION_DECK,0,1,nil)

    local use_cont = false
    if can_field and can_cont then
        -- 两种方式都可用，让玩家选择
        -- 选项0：放置「Roselia」；选项1：放置永续魔陷
        use_cont = Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))==1
    elseif can_cont then
        use_cont = true
    elseif not can_field then
        return
    end

    if use_cont then
        -- 放置记述「Roselia」的永续魔法·永续陷阱
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local g=Duel.SelectMatchingCard(tp,s.setfilter2,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        end
    else
        -- 放置「Roselia」到场地（自动覆盖旧场地）
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local g=Duel.SelectMatchingCard(tp,s.setfilter1,tp,LOCATION_DECK,0,1,1,nil)
        if #g>0 then
            Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_FZONE,POS_FACEUP,true)
        end
    end
end