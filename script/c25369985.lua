local s,id,o=GetID()
local SET_HOLY_NIGHT=0x159

function s.initial_effect(c)
    -- 超量召唤手续
    c:EnableReviveLimit()
    aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),7,2,s.ovfilter,aux.Stringid(id,0))

    -- ① 光属性从手卡特召时，拔素材盖魔陷（1回合最多2次）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_SEARCH+CATEGORY_DECKDES)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(2,id)
    e1:SetCondition(s.setcon)
    e1:SetCost(s.setcost)
    e1:SetTarget(s.settg)
    e1:SetOperation(s.setop)
    c:RegisterEffect(e1)

    -- ②（原③）光属性回手时，拔素材炸卡+加攻（1回合最多2次）
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_HAND)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(2,id+100)
    e2:SetCondition(s.descon)
    e2:SetCost(s.descost)
    e2:SetTarget(s.destg)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
end

-- 超量叠放条件：圣夜骑士超量怪兽
function s.ovfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_HOLY_NIGHT) and c:IsType(TYPE_XYZ)
end

-- ① 条件：自己从手卡把光属性怪兽特殊召唤
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.setfilter,1,nil,tp)
end
function s.setfilter(c,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:IsPreviousLocation(LOCATION_HAND)
        and c:GetPreviousControler()==tp
end

-- ① Cost：取除1个超量素材
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- ① Target：从卡组选圣夜骑士魔陷
function s.setfilter2(c)
    return c:IsSetCard(SET_HOLY_NIGHT) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter2,tp,LOCATION_DECK,0,1,nil) end
end

-- ① Operation：盖放到场上
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter2,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SSet(tp,g)
    end
end

-- ② 条件：自己场上的光属性怪兽回到手卡
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.desfilter,1,nil,tp)
end
function s.desfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_MZONE)
        and c:IsAttribute(ATTRIBUTE_LIGHT)
        and c:GetPreviousControler()==tp
end

-- ② Cost：取除1个超量素材
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end

-- ② Target：选场上1张卡破坏
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end

-- ② Operation：炸卡+加攻
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.HintSelection(g)
        if Duel.Destroy(g,REASON_EFFECT)>0 then
            local sg=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
            for tc in aux.Next(sg) do
                local e1=Effect.CreateEffect(e:GetHandler())
                e1:SetType(EFFECT_TYPE_SINGLE)
                e1:SetCode(EFFECT_UPDATE_ATTACK)
                e1:SetValue(500)
                e1:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(e1)
            end
        end
    end
end
function s.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_HOLY_NIGHT)
end