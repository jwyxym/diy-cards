--捕食日轮之角 
local this,id,ofs=GetID()
function this.initial_effect(c)
    aux.AddCodeList(c,31000201)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCondition(this.acon)
    e1:SetTarget(this.atg)
    e1:SetOperation(this.aop)
    c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22748199,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(this.setcon)
	e2:SetTarget(this.settg)
	e2:SetOperation(this.setop)
	c:RegisterEffect(e2)
end
function this.afilter(c)
    return (c:IsCode(31000201) or c:IsType(TYPE_RITUAL) and aux.IsCodeListed(c,31000201)) and c:IsFaceup()
end
function this.dfilter(c)
    return c:IsFaceup() and c:IsAttackBelow(3e3)
end
function this.acon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(this.afilter,tp,LOCATION_MZONE,0,1,nil)
end
function this.atg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) or Duel.IsExistingMatchingCard(this.dfilter,tp,0,LOCATION_MZONE,1,nil) end
end
function this.aop(e,tp,eg,ep,ev,re,r,rp)
    local b1=Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
    local b2=Duel.IsExistingMatchingCard(this.dfilter,tp,0,LOCATION_MZONE,1,nil)
    local op
    if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
    elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(id,0))
    elseif b2 then op=Duel.SelectOption(tp,aux.Stringid(id,1))+1
    else return end
    if op==0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local tc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
        if tc and #tc==1 then Duel.Destroy(tc,REASON_EFFECT) end
    elseif op==1 then
        local g=Duel.GetMatchingGroup(this.dfilter,tp,0,LOCATION_MZONE,nil)
        Duel.Destroy(g,REASON_EFFECT)
    end
end
function this.setfilter(c,tp)
	return c:IsFaceup() and aux.IsCodeListed(c,31000201) and c:IsType(TYPE_RITUAL) and c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsControler(tp)
end
function this.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(this.setfilter,1,nil,tp)
end
function this.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function this.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
