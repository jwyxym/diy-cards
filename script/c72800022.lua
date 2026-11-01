-- ⭐️Ebizuka Tomo⭐️
-- ID: 72800022
-- 光属性 / 幻想魔族 / 超量 / ATK 2600 / DEF 2100
-- 5星怪兽×2
-- 「Ebizuka Tomo」：72800013
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    -- 超量召唤：5星怪兽×2
    aux.AddXyzProcedure(c, nil, 5, 2)

    -- ② 1回合1次，取除1个超量素材，场上最多两张卡除外
    -- ① 没有「Ebizuka Tomo」作为超量素材的这张卡不能把效果发动（在条件中检查）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1,id)
    e1:SetCondition(s.rmcon)
    e1:SetCost(s.rmcost)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    c:RegisterEffect(e1)
end

-- ① 条件：超量素材中必须有「Ebizuka Tomo」(72800013)
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if not c:IsType(TYPE_XYZ) then return false end
    local mg=c:GetOverlayGroup()
    if not mg then return false end
    return mg:IsExists(Card.IsCode,1,nil,72800013)
end

-- ② cost：取除1个超量素材
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
    c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- ② 目标：场上存在可除外的卡（不取对象，处理时选择）
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD)
end

-- ② 操作：选择场上最多2张卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
    if #g==0 then return end
    local ct=math.min(2,#g)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local sg=g:Select(tp,1,ct,nil)
    if #sg>0 then
        Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
    end
end