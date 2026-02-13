--轩辕剑
function c61000074.initial_effect(c)
	c:SetUniqueOnField(1,0,61000074)
	
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c61000074.target)
	e1:SetOperation(c61000074.operation)
	c:RegisterEffect(e1)
	
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	
	--Attack restriction (only equipped monster can attack)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c61000074.atktg)
	c:RegisterEffect(e3)
	
	--Atk increase during damage calculation
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetCondition(c61000074.atkcon)
	e4:SetValue(c61000074.atkval)
	c:RegisterEffect(e4)
	
	--Piercing
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e5)
	
	--Effect activation restriction during battle
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_ATTACK_ANNOUNCE)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c61000074.lmcon)
	e6:SetOperation(c61000074.lmop)
	c:RegisterEffect(e6)
	
	--Double battle damage to opponent
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_EQUIP)
	e7:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e7:SetCondition(c61000074.damcon)
	e7:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e7)
end

function c61000074.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function c61000074.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and e:GetHandler():CheckUniqueOnField(tp) then
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end

function c61000074.atktg(e,c)
	-- Only monsters NOT equipped with this card cannot attack
	return not c:GetEquipGroup():IsContains(e:GetHandler())
end

function c61000074.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	local ph=Duel.GetCurrentPhase()
	return ec and ec==Duel.GetAttacker() and (ph>=PHASE_DAMAGE and ph<=PHASE_DAMAGE_CAL)
end

function c61000074.atkval(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	if tc and tc:IsFaceup() then
		return tc:GetAttack()
	else
		return 0
	end
end

function c61000074.lmcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and Duel.GetAttacker()==ec
end

function c61000074.lmop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if not ec or Duel.GetAttacker()~=ec then return end
	
	-- Opponent cannot activate effects until the end of Damage Step
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c61000074.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
	
	-- Also prevent monster effects during damage step
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TRIGGER)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(c61000074.trigtg)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
end

function c61000074.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or (re:IsActiveType(TYPE_MONSTER) and not rc:IsImmuneToEffect(e)))
end

function c61000074.trigtg(e,c)
	return c:IsStatus(STATUS_BATTLE_DESTROYED) or not c:IsImmuneToEffect(e)
end

function c61000074.damcon(e)
	return e:GetHandler():GetEquipTarget():GetBattleTarget()~=nil
end
