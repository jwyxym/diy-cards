-- 《<梦魇>夜之歌的演唱会》
-- 卡号：65200026
-- 类型：通常陷阱
local s,id=GetID()
local NM=0x32a

function s.initial_effect(c)
    -- ① 解放衍生物炸卡 + 可选烧血（Operation阶段解放）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target1)
    e1:SetOperation(s.operation1)
    c:RegisterEffect(e1)

    -- ② 这张卡被除外的场合才能发动，加入手卡或盖放（被动触发）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCode(EVENT_REMOVE)
    e2:SetCountLimit(1,id+100)
    e2:SetTarget(s.target2)
    e2:SetOperation(s.operation2)
    c:RegisterEffect(e2)
end

-- ① Target：条件检查
function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_TOKEN)
    local ct=math.min(3,#g)
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,nil) end
end

-- ① Operation：解放衍生物→炸卡→可选烧血
function s.operation1(e,tp,eg,ep,ev,re,r,rp)
    -- 选衍生物解放
    local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,0,nil,TYPE_TOKEN)
    if #g==0 then return end
    local max=math.min(3,#g)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local sg=g:Select(tp,1,max,nil)
    Duel.Release(sg,REASON_EFFECT)
    local num=#sg

    -- 炸对应数量的卡
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local dg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,num,num,nil)
    if #dg>0 then
        Duel.HintSelection(dg)
        Duel.Destroy(dg,REASON_EFFECT)
    end

    -- 可选：除外墓地最多6张卡，给予数量×300伤害
    local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil)
    if #rg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
        local max_remove=math.min(6,#rg)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local sg=rg:Select(tp,1,max_remove,nil)
        local ct=Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
        if ct>0 then Duel.Damage(1-tp,ct*300,REASON_EFFECT) end
    end
end

-- ② Target：确认能回手或盖放
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToHand() or c:IsSSetable() end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end

-- ② Operation：加入手卡或盖放
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsRelateToEffect(e) then return end
    if c:IsAbleToHand() and (not c:IsSSetable() or Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))==0) then
        Duel.SendtoHand(c,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,c)
    else
        Duel.SSet(tp,c)
    end
end