--穹瀛 邪惑归魂
local this,id,ofs=GetID()
function this.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),this.mfilter,false)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetValue(this.efilter)
	c:RegisterEffect(e6)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(this.imcon)
	e1:SetOperation(this.imop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+ofs)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(this.cttg)
	e2:SetOperation(this.ctop)
	c:RegisterEffect(e2)
end
function this.mfilter(c)
	return c:IsFusionSetCard(0x675) and c:IsType(TYPE_FUSION)
end
function this.efilter(e,te)
	return not te:GetHandler():IsAttribute(ATTRIBUTE_LIGHT) and te:IsActiveType(TYPE_MONSTER) and te:GetHandler()~=e:GetHandler()
end
function this.imfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function this.imcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
function this.imop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=rc:GetBaseAttack()
		if atk>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
			if Duel.IsExistingMatchingCard(this.imfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				local g=Duel.GetMatchingGroup(this.imfilter,tp,0,LOCATION_MZONE,nil)
				if #g>0 then
					Duel.BreakEffect()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
					local tc=g:Select(tp,1,1,nil)
					Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
				end
			end
		end
	end
end
function this.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,0,0)
end
function this.ctop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		Duel.GetControl(tc,tp)
	end
end
