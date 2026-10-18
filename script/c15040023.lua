-- 命运的共同体
-- 速攻魔法
-- ID: 15040023
-- 「春日影」：26062911
-- 「初次的邂逅 丰川祥子」：26062901
local s,id=GetID()
function s.initial_effect(c)
    aux.AddCodeList(c,26062911)  -- 此卡记述「春日影」

    -- ① 自己场上没有非「春日影」记述怪兽时，检索记述怪兽，若为「初次的邂逅 丰川祥子」可再盖放
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SSET)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.thcon)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)

    -- ② 自己场上的「春日影」或记述卡成为效果对象时，除外墓地的此卡无效
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_NEGATE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetHintTiming(0,TIMING_END_PHASE+TIMING_MAIN_END)
    e2:SetCountLimit(1,id+1)
    e2:SetCondition(s.negcon)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)
end

-- ① 条件：自己场上没有「春日影」记述以外的表侧怪兽
function s.nonfilter(c)
    return c:IsFaceup() and not aux.IsCodeListed(c,26062911)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return not Duel.IsExistingMatchingCard(s.nonfilter,tp,LOCATION_MZONE,0,1,nil)
end

-- ① 检索对象：记述「春日影」的怪兽
function s.thfilter(c)
    return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,26062911) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    Duel.SetOperationInfo(0,CATEGORY_SSET,nil,1,tp,LOCATION_DECK)
end

-- ① 盖放对象：「春日影」或有其卡名记述的魔法·陷阱
function s.setfilter(c)
    return (c:IsCode(26062911) or aux.IsCodeListed(c,26062911))
        and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    -- 自肃：发动后自己不是「春日影」记述怪兽不能从手卡·卡组特殊召唤
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.splimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g==0 then return end
    local tc=g:GetFirst()
    if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
        Duel.ConfirmCards(1-tp,tc)
        if tc:IsCode(26062901)
            and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
            Duel.BreakEffect()
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
            local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
            if #sg>0 then
                Duel.SSet(tp,sg:GetFirst())
            end
        end
    end
end

-- ① 自肃：非「春日影」记述怪兽不能从手卡·卡组特殊召唤
function s.splimit(e,c)
    if c:IsLocation(LOCATION_HAND) or c:IsLocation(LOCATION_DECK) then
        return not aux.IsCodeListed(c,26062911)
    end
    return false
end

-- ② 条件：对方发动的效果以自己场上的「春日影」或记述卡为对象
function s.negfilter(c,tp)
    return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
        and (c:IsCode(26062911) or aux.IsCodeListed(c,26062911))
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    if rp==tp then return false end
    if not Duel.IsChainNegatable(ev) then return false end
    local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
    if not tg or tg:GetCount()==0 then return false end
    return tg:IsExists(s.negfilter,1,nil,tp)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    Duel.NegateActivation(ev)
end