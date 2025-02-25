--清之萌素魔女契约者
local this,id,ofs=GetID()
function this.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x516),aux.FilterBoolFunction(Card.IsFusionAttribute,ATTRIBUTE_WATER+ATTRIBUTE_WIND),true)
	c:SetUniqueOnField(1,0,id)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SPELL+TYPE_TRAP))
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(this.con)
	e1:SetTarget(this.tg)
	e1:SetOperation(this.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(this.matcon)
	e5:SetOperation(this.matop)
	c:RegisterEffect(e5)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(this.valcheck)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(this.spcon)
	e2:SetTarget(this.sptg)
	e2:SetOperation(this.spop)
	c:RegisterEffect(e2)
end
function this.filter(c,att)
	return c:IsAttribute(att) and c:IsFaceupEx() and c:IsAbleToHand()
end
function this.con(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
function this.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local att=0
	local c=e:GetHandler()
	for tc in aux.Next(eg) do
		att=att|tc:GetAttribute()
	end
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and this.filter(chkc,att) end
	if chk==0 then return Duel.IsExistingTarget(this.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,att) end-- and c:GetFlagEffect(id)<c:GetFlagEffectLabel(id+1) end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,aux.NecroValleyFilter(this.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,att)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,tc:GetFirst():GetLocation())
end
function this.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,tp,REASON_EFFECT) end
end
function this.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()>0
end
function this.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1,e:GetLabel())
end
function this.valcheck(e,c)
	local g=c:GetMaterial()
	local ct=g:FilterCount(Card.IsFusionSetCard,nil,0x516)
	e:GetLabelObject():SetLabel(ct)
end
function this.thfilter1(c,tp)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsFaceupEx() and c:IsAbleToHand() and Duel.IsExistingTarget(this.thfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,c)
end
function this.thfilter2(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceupEx() and c:IsAbleToHand()
end
function this.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:GetReasonPlayer()==1-tp
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(this.thfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=Duel.SelectTarget(tp,this.thfilter1,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc2=Duel.SelectTarget(tp,this.thfilter2,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,tc:GetFirst())
	tc:Merge(tc2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,2,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc1=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.SendtoHand(tc1,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tc1)
end
