-- 《<梦魇>夜之歌的演唱会》
-- 卡号：65200026  通常陷阱
local s,id=GetID()
local NM=0x32a

function s.initial_effect(c)
    -- ① 解放衍生物炸卡 + 可选烧血
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)

    -- ② 墓地除外检索
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCost(s.cost2)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.operation2)
    c:RegisterEffect(e2)
end

-- ① Target：只做条件检查
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_TOKEN)
    local ct=math.min(3,#g)
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,nil) end
end

-- ① Operation：解放衍生物→炸卡→可选烧血
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_TOKEN)
    if #g==0 then return end
    local max=math.min(3,#g)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local sg=g:Select(tp,1,max,nil)
    Duel.Release(sg,REASON_EFFECT)
    local num=#sg

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,num,num,nil)
    if #dg>0 then
        Duel.HintSelection(dg)
        Duel.Destroy(dg,REASON_EFFECT)
    end

    local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil)
    if #rg>0 and Duel.SelectYesNo(tp,"除外墓地最多6张卡，给予对方数量×300伤害吗？") then
        local max_remove=math.min(6,#rg)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg=rg:Select(tp,1,max_remove,nil)
        local ct=Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
        if ct>0 then Duel.Damage(1-tp,ct*300,REASON_EFFECT) end
    end
end

-- ② Cost：除外墓地里的这张卡
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToRemove() end
    Duel.Remove(c,POS_FACEUP,REASON_COST)
end

-- ② Target：检索
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- ② Operation：检索
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- 检索过滤
function s.thfilter(c,tp)
    return c:IsSetCard(NM) and c:IsAbleToHand()
        and not Duel.IsExistingMatchingCard(s.namecheck,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
function s.namecheck(c,code)
    return c:IsCode(code)
end