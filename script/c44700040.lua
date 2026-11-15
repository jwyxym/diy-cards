local s,id=GetID()
local SET_MOKUSHOKU=0x747

function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),7,2)

    -- ① 超量召唤成功：检索同种类「暮蚀」并送墓目标卡
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- ② 场上以外效果发动：效果送墓魔陷区卡康掉，被无效卡非暗怪则回额外并复活墓地
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_TOGRAVE+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

-- ① 过滤器：判断是否同种类
function s.thfilter(c,tc)
    if not c:IsSetCard(SET_MOKUSHOKU) then return false end
    if c:IsType(TYPE_MONSTER) and tc:IsType(TYPE_MONSTER) then return true end
    if c:IsType(TYPE_SPELL) and tc:IsType(TYPE_SPELL) then return true end
    if c:IsType(TYPE_TRAP) and tc:IsType(TYPE_TRAP) then return true end
    return false
end

-- ★ 主人修复的地方：改用 IsSummonType(SUMMON_TYPE_XYZ) 判断超量召唤
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFaceup() end
    if chk==0 then 
        local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
        return g:IsExists(function(tc)
            return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil,tc)
        end, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if not tc or not tc:IsRelateToEffect(e) then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil,tc)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end

    if tc:IsRelateToEffect(e) then
        Duel.SendtoGrave(tc,REASON_EFFECT)
    end
end

-- ② 条件：场上以外发动
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local ec=eg:GetFirst()
    return re and ec and not ec:IsLocation(LOCATION_ONFIELD)
end

-- ② Target
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_SZONE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
end

-- ② Operation：先效果送墓魔陷 -> 无效并返回卡组 -> 判断被无效的卡
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ec=eg:GetFirst()
    
    -- 效果处理：选择并送去墓地
    if not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_SZONE,0,1,nil) then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_SZONE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end

    -- 无效发动并回到卡组
    if ec and Duel.NegateEffect(ev)~=0 then
        Duel.SendtoDeck(ec,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
        
        -- 判断：被无效的卡（ec）是不是暗属性怪兽以外的卡
        local is_dark_monster = ec:IsType(TYPE_MONSTER) and ec:IsAttribute(ATTRIBUTE_DARK)
        
        if not is_dark_monster then
            -- 这张卡回到额外卡组
            if c:IsLocation(LOCATION_MZONE) then
                Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
            end
            
            -- 从墓地特召暮蚀怪兽
            if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
                local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(function(sc)
                    return sc:IsSetCard(SET_MOKUSHOKU) and sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
                end),tp,LOCATION_GRAVE,0,1,1,nil)
                if #sg>0 then
                    Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
                end
            end
        end
    end
end