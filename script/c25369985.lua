local s,id=GetID()
local SET_HOLY_NIGHT=0x159

function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),7,2,s.ovfilter,aux.Stringid(id,0))

    -- 全局监视：本回合自己特召非超量怪兽时设置标记
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetOperation(s.regflag)
    c:RegisterEffect(e0)

    -- ① 光属性从手卡特召时，拔素材盖魔陷（1回合最多2次）
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_DECKDES)
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

    -- ② 光属性回手时，拔素材炸卡+加攻（1回合最多2次）
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

function s.ovfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_HOLY_NIGHT) and c:IsType(TYPE_XYZ)
end

-- 监视特召：如果是自己特召非超量怪兽，设置标记
function s.regflag(e,tp,eg,ep,ev,re,r,rp)
    for tc in aux.Next(eg) do
        if tc:IsControler(tp) and not tc:IsType(TYPE_XYZ) then
            Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
            return
        end
    end
end

-- ① 条件：光属性从手卡特召 + 本回合未特召过非超量
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
        and eg:IsExists(s.setfilter,1,nil,tp)
end
function s.setfilter(c,tp)
    return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsPreviousLocation(LOCATION_HAND) and c:GetPreviousControler()==tp
end
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.setfilter2(c)
    return c:IsSetCard(SET_HOLY_NIGHT) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter2,tp,LOCATION_DECK,0,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
    -- 发动后自肃：直到回合结束不能特召非超量
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.xyzlimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter2,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then Duel.SSet(tp,g) end
end

-- ② 条件：光属性回手 + 本回合未特召过非超量
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFlagEffect(tp,id)==0
        and eg:IsExists(s.desfilter,1,nil,tp)
end
function s.desfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:GetPreviousControler()==tp
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
    e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    -- 发动后自肃：直到回合结束不能特召非超量
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetTargetRange(1,0)
    e1:SetTarget(s.xyzlimit)
    e1:SetReset(RESET_PHASE+PHASE_END)
    Duel.RegisterEffect(e1,tp)

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if #g>0 then
        Duel.HintSelection(g)
        if Duel.Destroy(g,REASON_EFFECT)>0 then
            local sg=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,0,nil)
            for tc in aux.Next(sg) do
                local ae=Effect.CreateEffect(e:GetHandler())
                ae:SetType(EFFECT_TYPE_SINGLE)
                ae:SetCode(EFFECT_UPDATE_ATTACK)
                ae:SetValue(500)
                ae:SetReset(RESET_EVENT+RESETS_STANDARD)
                tc:RegisterEffect(ae)
            end
        end
    end
end
function s.xyzlimit(e,c)
    return not c:IsType(TYPE_XYZ)
end
function s.atkfilter(c)
    return c:IsFaceup() and c:IsSetCard(SET_HOLY_NIGHT)
end