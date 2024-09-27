--暴风雨后的小辞
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetCost(this.acost)
    e1:SetTarget(this.atg)
    e1:SetOperation(this.aop)
    c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCountLimit(1,id+1)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCondition(this.con)
    e2:SetTarget(this.tg)
    e2:SetOperation(this.op)
    c:RegisterEffect(e2)
end
function this.afilter(c)
    return c:IsReleasable() and c:IsAttribute(ATTRIBUTE_DARK)
end
function this.acost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(this.afilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
    local tc=Duel.SelectMatchingCard(tp,this.afilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
    Duel.Release(tc,REASON_COST)
end
function this.atg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function this.aop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function this.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x676) and c:IsSSetable()
end
function this.con(e,tp,eg,ep,ev,re,r,rp)
    local rc
    if bit.band(r,REASON_RULE)~=0 then return false end
    if re then rc=re:GetHandler()
    else rc=e:GetHandler():GetReasonCard() end
    return rc:IsRace(RACE_SPELLCASTER)
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.filter,tp,LOCATION_GRAVE,0,1,nil) end
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,this.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
