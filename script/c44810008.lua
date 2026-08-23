--次元盗具 真视望远镜
local s,id,o=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_EQUIP)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
    --equip limit
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_EQUIP_LIMIT)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetValue(s.eqlim)
    c:RegisterEffect(e2)
    --double attack
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,id+id)
    e4:SetCost(s.cost)
    e4:SetCondition(s.dacon)
    e4:SetTarget(s.datg)
    e4:SetOperation(s.daop)
    c:RegisterEffect(e4)
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_IGNITION)
    e6:SetRange(LOCATION_SZONE)
    e6:SetCountLimit(1,id+id)
    e6:SetCondition(s.dacon1)
    e6:SetCost(s.dacost)
    e6:SetTarget(s.datg1)
    e6:SetOperation(s.daop1)
    c:RegisterEffect(e6)
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_EQUIP)
    e5:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
    e5:SetValue(s.valcon)
    e5:SetCountLimit(1)
    c:RegisterEffect(e5)
end
function s.valcon(e,re,r,rp)
    return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
function s.filter(c)
    return c:IsFaceup() and s.eqlim(nil,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
    if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
    Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then Duel.Equip(tp,c,tc) end
end
function s.eqlim(e,c)
    return c:IsSetCard(0x5ce1)
end
function s.dacon(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetHandler():GetEquipTarget()
    return tc:GetControler()==tp
end
function s.dacon1(e,tp,eg,ep,ev,re,r,rp)
    local tc=e:GetHandler():GetEquipTarget()
    return tc:GetControler()==1-tp
end
function s.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1500) end
    Duel.PayLPCost(tp,1500)
end
function s.spfilter(c,e,tp)
    return c:IsFaceupEx() and c:IsSetCard(0x5ce1)
        and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.costfilter(c)
    return c:IsSetCard(0x5ce1) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
    Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.datg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.daop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    if g:GetCount()>0 then
        Duel.HintSelection(g)
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end
function s.datg1(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return e:GetHandler():GetEquipTarget():IsControlerCanBeChanged() end
    Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))
    Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function s.daop1(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
        local tc=c:GetEquipTarget()
        if tc then
            Duel.GetControl(tc,tp)
        end
    end
end