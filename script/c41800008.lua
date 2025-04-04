--无垠之花·苗圃
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_DAMAGE)
    e1:SetCountLimit(1,id)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(this.con)
    e1:SetTarget(this.tg)
    e1:SetOperation(this.op)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCost(aux.bfgcost)
    e2:SetTarget(this.rtg)
    e2:SetOperation(this.rop)
    c:RegisterEffect(e2)
end
function this.filter(c)
    return c:IsType(TYPE_XYZ+TYPE_LINK) or c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
function this.con(e,tp,eg,ep,ev,re,r,rp)
    return r&REASON_EFFECT~=0
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=Duel.SelectMatchingCard(tp,this.filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
    if tc then Duel.SendtoGrave(tc,REASON_EFFECT) end
end
function this.rfilter1(c,tp)
    return c:IsSetCard(0x3410) and c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS and Duel.IsExistingTarget(this.rfilter2,tp,LOCATION_GRAVE,0,1,c,c:IsSSetable(),c:IsAbleToRemove())
end
function this.rfilter2(c,b1,b2)
    return c:IsSetCard(0x3410) and c:GetType()==TYPE_TRAP+TYPE_CONTINUOUS and (b1 and c:IsAbleToRemove() or b2 and c:IsSSetable())
end
function this.rtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and this.rfilter1(chkc,tp) end
    if chk==0 then return Duel.IsExistingTarget(this.rfilter1,tp,LOCATION_GRAVE,0,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc1=Duel.SelectTarget(tp,this.rfilter1,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc2=Duel.SelectTarget(tp,this.rfilter2,tp,LOCATION_GRAVE,0,1,1,tc1,tc1:IsSSetable(),tc1:IsAbleToRemove())
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function this.rop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
    local tg=Duel.GetTargetsRelateToChain()
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local tc=tg:FilterSelect(tp,Card.IsSSetable,1,1,nil):GetFirst()
    if tc then
        Duel.SSet(tp,tc)
        tg:RemoveCard(tc)
        Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
    end
end
