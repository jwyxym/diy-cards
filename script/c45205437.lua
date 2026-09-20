--反伤盾
local s,id=GetID()
function s.initial_effect(c)
	--手卡发动
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)
	
	--①效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetCondition(s.actcon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end

function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	local ph=Duel.GetCurrentPhase()
	return Duel.GetTurnPlayer()==1-tp and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end

function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	
	--自己受到的战斗伤害由对方代受
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
	
	--自己场上的怪兽受到的战斗伤害由对方代受
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetValue(1)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e3,tp)
	
	--对方受到的战斗伤害减半
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(HALF_DAMAGE)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e4,tp)
	
	--发动时自己场上没有怪兽，对方强制攻击
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 then
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD)
		e5:SetCode(EFFECT_MUST_ATTACK)
		e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
		e5:SetRange(LOCATION_SZONE)
		e5:SetTargetRange(0,1)
		e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e5,tp)
		
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_FIELD)
		e6:SetCode(EFFECT_MUST_ATTACK)
		e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e6:SetRange(LOCATION_SZONE)
		e6:SetTargetRange(0,LOCATION_MZONE)
		e6:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e6,tp)
	end
end

return s