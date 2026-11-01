local s,id=GetID() 
local id_abyss = 54700000

function s.initial_effect(c)
    aux.AddCodeList(c, id_abyss)

    -- ① 速攻魔法发动效果
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1,id) 
    e1:SetCost(s.descost)
    e1:SetTarget(s.eftg)
    e1:SetOperation(s.efop)
    c:RegisterEffect(e1)

    -- ② 被丢弃加入手卡或盖放
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(2,id+1) 
    e2:SetCondition(s.setcon)
    e2:SetTarget(s.settg)
    e2:SetOperation(s.setop)
    c:RegisterEffect(e2)
    
    -- ★ 强行赋予盖放当回合发动的能力
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
    e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
    c:RegisterEffect(e3)
end

-- ① Cost：丢弃2张以上手卡，并记录数量
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) end
    local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
    local sg=g:Select(tp,2,99,nil)
    e:SetLabel(#sg) -- ★ 记录丢了几张
    Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
end

-- ① Target：选场上1张表侧卡
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFaceup() end
    if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end

-- 特召过滤器
function s.spfilter(c,e,tp)
    return aux.IsCodeListed(c, id_abyss) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ① 效果处理：无效 -> 判定丢了几张 -> 决定是否特召
function s.efop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=e:GetLabel()
    local tc=Duel.GetFirstTarget()
    
    -- 第一步：无效目标卡
    if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=e1:Clone()
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        tc:RegisterEffect(e2)
    end

    -- 第二步：如果丢弃了3张以上，可以特召
    if ct >= 3 then
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) then
            if Duel.SelectYesNo(tp, aux.Stringid(id,3)) then
                Duel.BreakEffect()
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
                if #sg>0 then
                    Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
                end
            end
        end
    end
end

-- ② 条件：被丢弃
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and e:GetHandler():IsReason(REASON_DISCARD)
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
end

-- ② 效果处理：加入手卡或盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    
    local op = Duel.SelectOption(tp, aux.Stringid(id,4), aux.Stringid(id,5))
    if op == 0 then
        Duel.SendtoHand(c, nil, REASON_EFFECT)
        Duel.ConfirmCards(1-tp, c)
    else
        if Duel.GetLocationCount(tp,LOCATION_SZONE) > 0 then
            Duel.SSet(tp, c)
            c:SetStatus(STATUS_SET_TURN, false)
        end
    end
end