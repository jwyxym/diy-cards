--百鬼夜行
local cm,m,o=GetID()
Duel.LoadScript("c666Hyakkiyakou.lua")
function cm.initial_effect(c)
	c:SetUniqueOnField(1,0,m)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	xiaoye.PendulumRepalce(c)
	xiaoye.MonsterEffectAndGrant(c,m,0,EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD,EVENT_ATTACK_ANNOUNCE,0,0,cm.con,cm.tg,cm.op,EFFECT_FLAG_CARD_TARGET)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():GetControler()~=tp
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc==Duel.GetAttacker() end
	if chk==0 then return Duel.GetAttacker():IsCanBeEffectTarget(e)
		and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	Duel.SetTargetCard(Duel.GetAttacker())
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
		Duel.NegateAttack()
end