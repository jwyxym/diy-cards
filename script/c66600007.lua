--百鬼夜行
local cm,m,o=GetID()
Duel.LoadScript("c666Hyakkiyakou.lua")
function cm.initial_effect(c)
	c:SetUniqueOnField(1,0,m)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	xiaoye.PendulumRepalce(c)
	xiaoye.MonsterEffectAndGrant(c,m,CATEGORY_ATKCHANGE,EFFECT_TYPE_QUICK_O,EVENT_FREE_CHAIN,TIMINGS_CHECK_MONSTER+TIMING_BATTLE_START+TIMING_ATTACK,0,0,cm.tg,cm.op,0)
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.nzatk(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.nzatk,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.nzatk,tp,0,LOCATION_MZONE,1,1,nil)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end