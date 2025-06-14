--不朽机骸 禁断的一击
function c31280145.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,31280145+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c31280145.condition)
	e1:SetCost(c31280145.cost)
	e1:SetTarget(c31280145.target)
	e1:SetOperation(c31280145.activate)
	c:RegisterEffect(e1)
	--装备 
    local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
    e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,31380145)
    e2:SetCondition(aux.exccon)
	e2:SetTarget(c31280145.target1)
	e2:SetOperation(c31280145.operation1)
	c:RegisterEffect(e2) 
end
function c31280145.condition(e,tp,eg,ep,ev,re,r,rp)
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)) and Duel.IsChainNegatable(ev)
end
function c31280145.cfilter(c,tp)
	return (c:IsRace(RACE_MACHINE) and c:GetOriginalRace()==RACE_ZOMBIE) and (c:IsControler(tp) or c:IsFaceup()) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c31280145.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c31280145.cfilter,1,nil,tp) end
	local sg=Duel.SelectReleaseGroup(tp,c31280145.cfilter,1,1,nil,tp)
	Duel.Release(sg,REASON_COST)
end
function c31280145.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function c31280145.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) and Duel.Destroy(rc,REASON_EFFECT)~=0 and rc:GetBaseAttack()>=0
		and not rc:IsPreviousLocation(LOCATION_SZONE) and (rc:IsPreviousLocation(LOCATION_MZONE) or rc:GetOriginalType()&TYPE_MONSTER~=0)
		and c:IsRelateToEffect(e) then
		local atk=math.max(0,rc:GetTextAttack())
		if atk>0 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,atk/2,REASON_EFFECT)
		end            
    end        
end
function c31280145.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_FUSION)
end
function c31280145.target1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31280145.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c31280145.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c31280145.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function c31280145.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsControler(tp) then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or not tc:IsLocation(LOCATION_MZONE) then
			Duel.SendtoGrave(c,REASON_EFFECT)
			return
		end
		if not Duel.Equip(tp,c,tc) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(c31280145.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)		
		--除外        
        local e2=Effect.CreateEffect(c)
        e2:SetDescription(aux.Stringid(312801445,0))
		e2:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e2:SetCategory(CATEGORY_REMOVE)
		e2:SetCode(EVENT_BATTLE_START)
		e2:SetRange(LOCATION_SZONE)
        e2:SetCountLimit(1)
		e2:SetCondition(c31280145.condition2)
		e2:SetTarget(c31280145.target2)
		e2:SetOperation(c31280145.operation2)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)      
	end
end
function c31280145.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function c31280145.condition2(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetHandler():GetEquipTarget()
	return tg and (Duel.GetAttacker()==tg or Duel.GetAttackTarget()==tg)
end
function c31280145.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) end
	local g=Group.FromCards(tc,c)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
function c31280145.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=c:GetEquipTarget():GetBattleTarget()
	if tc:IsRelateToBattle() and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
    	tc:RegisterFlagEffect(31280145,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(c31280145.condition3)
		e1:SetOperation(c31280145.operation3)
		e1:SetLabel(Duel.GetTurnCount())
		Duel.RegisterEffect(e1,tp)
	end
end
function c31280145.condition3(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(31280145)~=0
end
function c31280145.operation3(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end