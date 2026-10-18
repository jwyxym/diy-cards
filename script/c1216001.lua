local s,id,o=GetID()
function s.initial_effect(c)
	--永续魔法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	--①怪兽给予自己·对方战斗伤害的场合，有概率使那次战斗伤害变为原本的2.5次方
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local original_dmg = ev
	-- 1~100随机，1%触发
	local rnd = math.random(1,100)
	if rnd == 1 then
		-- x^2.5 = x*x * sqrt(x)
		local new_dmg = math.floor( original_dmg * original_dmg * math.sqrt(original_dmg) )
		Duel.ChangeBattleDamage(ep, new_dmg)
	end
end
