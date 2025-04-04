--幻灭无垠之花
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCost(this.cost)
	c:RegisterEffect(e2)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1,id)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetTarget(this.tg)
    e1:SetOperation(this.op)
    c:RegisterEffect(e1)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,1))
    e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_ONFIELD)
    e1:SetCountLimit(1,id+1)
    e1:SetTarget(this.thtg)
    e1:SetOperation(this.thop)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    c:RegisterEffect(e2)
end
function this.cfilter(c)
    return c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function this.cost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local tc=Duel.SelectMatchingCard(tp,this.cfilter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
    Duel.SendtoGrave(tc,REASON_COST)
end
function this.rfilter(c)
    return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER) or c:IsLocation(LOCATION_MZONE)
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and chkc:IsControler(1-tp) and this.rfilter(chkc) end
	if chk==0 then return e:IsCostChecked()
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x3410,TYPES_EFFECT_TRAP_MONSTER,1400,1400,2,RACE_FAIRY,ATTRIBUTE_DARK)
        and Duel.IsExistingTarget(this.rfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,this.rfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
        if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x3410,TYPES_EFFECT_TRAP_MONSTER,1400,1400,2,RACE_FAIRY,ATTRIBUTE_DARK) then return end
        c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
        Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
    end
end
function this.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,1200)
end
function this.thop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.Recover(tp,2000,REASON_EFFECT)>0 then
        Duel.BreakEffect()
        Duel.Damage(tp,1200,REASON_EFFECT)
    end
end
