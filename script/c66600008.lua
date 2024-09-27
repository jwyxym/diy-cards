--百鬼夜行
local cm,m,o=GetID()
Duel.LoadScript("c666Hyakkiyakou.lua")
function cm.initial_effect(c)
	c:SetUniqueOnField(1,0,m)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	xiaoye.PendulumRepalce(c)
	xiaoye.MonsterEffectAndGrant(c,m,0,EFFECT_TYPE_QUICK_O,EVENT_FREE_CHAIN,TIMING_END_PHASE+TIMING_DRAW+TIMING_DRAW_PHASE,0,0,cm.tg,cm.op,0)
end
function cm.filter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local sg=Duel.GetMatchingGroup(cm.filter,tp,0,LOCATION_SZONE,nil)
	if g:GetCount()>0 then
		Duel.ConfirmCards(tp,g)
		Duel.BreakEffect()
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(m,1)) then Duel.ConfirmCards(tp,sg)
		elseif sg:GetCount()==0 then Duel.SelectOption(tp,aux.Stringid(m,2))
		end
		Duel.ShuffleHand(1-tp)
	end
end
