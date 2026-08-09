--
function c19993024.initial_effect(c)
	c:SetSPSummonOnce(19993024)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19993024+EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(c19993024.skipcost)
	e1:SetOperation(c19993024.skipop)
	c:RegisterEffect(e1)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xb35))
	c:RegisterEffect(e2)
	--Effect monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_ADD_TYPE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e3)
	--actlimit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(c19993024.aclimit)
	e4:SetCondition(c19993024.actcon)
	c:RegisterEffect(e4)
end
function c19993024.skipfilter(c,tp)
	return (c:IsSetCard(0xb35) and ((c:IsType(TYPE_SYNCHRO) and c:IsLevel(12)) or (c:IsType(TYPE_XYZ) and c:IsRank(8))) and (c:IsControler(tp) or c:IsFaceup()) )or (c:IsHasEffect(19993032,tp) and c:IsControler(1-tp)) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function c19993024.skipcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c19993024.skipfilter,1,nil,tp) end
	local g=Duel.SelectReleaseGroup(tp,c19993024.skipfilter,1,1,nil,tp)
	Duel.Release(g,REASON_COST)
end
function c19993024.skipop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_M1)
	if Duel.GetTurnPlayer()==1-tp then
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c19993024.turncon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	end
	Duel.RegisterEffect(e1,tp)
end
function c19993024.turncon(e)
	return Duel.GetTurnCount()~=e:GetLabel()
end
function c19993024.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)
end
function c19993024.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end